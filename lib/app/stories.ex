defmodule App.Stories do
  import Ecto.Query, warn: false
  require Logger

  alias App.Repo
  alias Ecto.Multi
  alias App.Stories.{Story, StoryCategory, StoryAuthor, StorySearch}

  def count(schema) do
    Repo.aggregate(schema, :count)
  end

  def random(schema) do
    hd randoms(schema, 1)
  end

  def randoms(schema, count) do
    from(schema, order_by: fragment("RANDOM()"), limit: ^count) |> Repo.all
  end

  # Category
  def list_story_categories(only_visible? \\ true) do
    q = StoryCategory
    q =
      if only_visible? do
        where(q, is_visible: true)
      else
        q
      end

    Repo.all(q)
  end

  def get_story_category!(id), do: Repo.get!(StoryCategory, id)

  def get_story_categories(oids) do
    StoryCategory |> where([t], t.oid in ^oids) |> Repo.all
  end

  def create_story_category(attrs \\ %{}) do
    %StoryCategory{}
    |> StoryCategory.changeset(attrs)
    |> Repo.insert()
  end

  def set_visible(%StoryCategory{} = cat, is_visible) do
    cat
    |> StoryCategory.changeset(%{is_visible: is_visible})
    |> Repo.update!
  end

  # Author
  def list_story_authors do
    Repo.all(StoryAuthor)
  end

  def get_story_author!(id), do: Repo.get!(StoryAuthor, id)

  def create_story_author(attrs \\ %{}) do
    %StoryAuthor{}
    |> StoryAuthor.changeset(attrs)
    |> Repo.insert()
  end

  # Story
  def list_stories(args \\ %{}, is_favorites \\ false) do
    query = args["query"]
    author_id = args["author_id"]
    cat_ids = args["cat_ids"]
    rating = args["rating"]
    sort = (args["sort"] || "story_date") |> String.to_existing_atom
    sort_dir = (args["sort_dir"] || "desc_nulls_last") |> String.to_existing_atom

    q = Story

    q = if is_favorites do
      from s in q, where: not is_nil(s.favorited_at)
    else
      q
    end

    q = if author_id do
      from s in q, join: a in assoc(s, :story_author), where: a.id == ^author_id
    else
      q
    end

    q = if rating do
      where(q, [t], t.rating > ^rating and t.rating_count > 10)
    else
      q
    end

    q = if cat_ids && cat_ids != [] do
      cat_ids = List.flatten [cat_ids]
      Enum.reduce cat_ids, q, fn cat_id, q ->
        if cat_id && cat_id != "" do
          from s in q, join: c in assoc(s, :story_categories), where: c.id == ^cat_id
        else
          q
        end
      end
    else
      q
    end

    q = if is_favorites do
      order_by(q, desc: :favorited_at)
    else
      order_by(q, {^sort_dir, ^sort})
    end

    q = if query && String.length(query) > 2 do
      sq = search_stories(query)
      from s in q, where: s.id in subquery(sq)
    else
      q
    end

    q
  end

  def get_story!(id) do
    Story |> Repo.get!(id) |> load_story_body()
  end

  def create_story(attrs \\ %{}) do
    story = Story.changeset(%Story{}, attrs)

    res =
      Multi.new
      |> Multi.insert(:story, story)
      |> Multi.run(:file, fn _repo, %{story: story} -> save_story_body(story) end)
      |> Multi.insert(:story_search, fn %{story: story} -> StorySearch.changeset(story) end)
      |> Repo.transaction

    with {:ok, %{story: story}} <- res do
      {:ok, story}
    else
      err ->
        Logger.error(inspect(err))
        err
    end
  end

  def delete_story(%Story{} = story) do
    Repo.delete(story)
  end

  def story_file(story) do
    folder = Application.get_env(:app, :story_storage, "priv/db/story_body")
    File.mkdir_p!(folder)
    Path.join(folder, "#{story.id}.html")
  end

  def save_story_body(story) do
    file = story_file(story)
    with :ok <- File.write(file, story.story_body) do
      {:ok, file}
    end
  end

  def load_story_body(story) do
    file = story_file(story)

    with {:ok, story_body} <- File.read(file) do
      %{story | story_body: story_body}
    else
      _ -> %{story | story_body: :not_found}
    end
  end

  def set_favorite(id) do
    story = Repo.get!(Story, id)
    favorited_at = if story.favorited_at, do: nil, else: DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)

    story
    |> Story.set_favorite(favorited_at)
    |> Repo.update!
  end

  def set_story_categories(story, {:objects, cats}) do
    story
    |> Repo.preload(:story_categories)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:story_categories, cats)
    |> Repo.update!
  end

  def set_story_categories(story, {:ids, cat_ids}) do
    entries = Enum.map cat_ids, & %{story_id: story.id, story_category_id: &1}
    Repo.insert_all "stories_categories_join", entries
  end

  # Search
  def search(query) do
    from(StorySearch,
      select: [:title, :rank, :id],
      where: fragment("story_search MATCH ?", ^query),
      order_by: [asc: :rank]
    )
    |> Repo.all
  end

  def search_stories(query) do
    from ss in StorySearch,
      where: fragment("story_search MATCH ?", ^query),
      select: ss.id
  end
end
