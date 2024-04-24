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

    parse_bsondump bd_file, fn obj, i ->
      if rem(i, 1000) == 0, do: IO.puts(i)

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
        err ->
          Logger.error(inspect(err))
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

  def create_fake(fake_fn) do
    try do
      fake_fn.()
    rescue
      _ ->
        Logger.error("!create_fake")
        create_fake(fake_fn)
    end
  end

  def load_fake_data(cat_count, author_count, story_count) do
    Logger.info "load_fake_data(#{cat_count}, #{author_count}, #{story_count})"

    Enum.each 1..cat_count, fn i ->
      create_fake fn ->
        attrs = %{
          name: Faker.Industry.industry,
          uid: i,
          oid: "oid#{i}"
        }

        Stories.create_story_category(attrs)
      end
    end

    Enum.each 1..author_count, fn i ->
      create_fake fn ->
        attrs = %{
          name: Faker.Person.first_name <> " " <> Faker.Person.last_name,
          uid: i,
          oid: "oid#{i}"
        }

        Stories.create_story_author(attrs)
      end
    end

    Enum.each 1..story_count, fn i ->
      create_fake fn ->
        p1 = Faker.Lorem.paragraph
        p2 = [p1 | Faker.Lorem.paragraphs(20 + :rand.uniform(20))] |> Enum.map(&( "<p>#{&1}</p>" ))

        attrs = %{
          story_date: Faker.DateTime.backward(365),
          story_excerpt: p1,
          story_body: Enum.join(p2, "\n"),
          rating: Float.round(:rand.uniform * 10, 2),
          rating_count: :rand.uniform(99),
          title: Faker.Lorem.sentence,
          uid: i,
          story_author_id: Stories.random(Stories.StoryAuthor).id,
        }

        {:ok, story} = Stories.create_story(attrs)
        Stories.set_story_categories(story, {:objects, Stories.randoms(Stories.StoryCategory, :rand.uniform(3))})
      end
    end
  end
end
