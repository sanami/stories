defmodule Tex.Stories.Loader do
  require Logger

  alias Tex.Stories

  def parse_bsondump(file, obj_fn) do
    Logger.info "Tex.Stories.Loader.parse_bsondump #{file}"

    file
    |> File.stream!([:read], :line)
    |> Stream.with_index
    |> Enum.reduce(0, fn {json_str, i}, _acc ->
      json = Jason.decode!(json_str, keys: :atoms)

      json
      |> Map.put(:oid, json[:_id][:"$oid"])
      |> Map.delete(:_id)
      |> obj_fn.(i)

      i + 1
    end)
  end

  def load_categories(bd_file) do
    parse_bsondump bd_file, fn obj, _i ->
      {status, obj} = Stories.create_story_category %{name: obj[:story_category_name], uid: obj[:uid], oid: obj[:oid]}
      if status != :ok, do: Logger.error(obj.errors)
    end
  end

  def load_authors(bd_file) do
    parse_bsondump bd_file, fn obj, _i ->
      {status, obj} = Stories.create_story_author %{name: obj[:story_author_name], uid: obj[:uid], oid: obj[:oid]}
      if status != :ok, do: Logger.error(obj.errors)
    end
  end

  def load_stories(bd_file) do
    {category_by_oid, author_by_oid} = cache_data()

    parse_bsondump bd_file, fn obj, _i ->
      attrs = %{
        story_date: obj[:story_date][:"$date"],
        story_excerpt: obj[:story_excerpt],
        story_body: Enum.join(obj[:story_body], "\n"),
        rating: obj[:story_rating][:value],
        rating_count: obj[:story_rating][:count],
        title: obj[:story_title],
        uid: obj[:uid],
        story_author_id: author_by_oid[obj[:story_author_id][:"$oid"]].id,
      }

      case Stories.create_story(attrs) do
        {:ok, story} ->
          cat_oids = get_in(obj, [:story_category_ids, Access.all, :"$oid"])
          Logger.debug cat_oids

          # cats = Stories.get_story_categories(cat_oids)
          cat_ids = Enum.map cat_oids, & category_by_oid[&1].id

          Stories.set_story_categories(story, {:ids, cat_ids})
        {:error, cs} ->
          Logger.error(cs.errors)
      end
    end
  end

  def cache_data do
    all_cats_by_oid =
      Enum.reduce(Stories.list_story_categories, %{}, fn x, acc ->
        Map.put(acc, x.oid, x)
      end)
    all_authors_by_oid =
      Enum.reduce(Stories.list_story_authors, %{}, fn x, acc ->
        Map.put(acc, x.oid, x)
      end)

    {all_cats_by_oid, all_authors_by_oid}
  end
end
