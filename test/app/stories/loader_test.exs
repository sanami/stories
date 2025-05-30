defmodule App.Stories.LoaderTest do
  use App.DataCase

  import App.StoriesFixtures
  import Ecto.Query

  alias App.{Repo, Stories}
  alias App.Stories.{Loader, Story, StoryAuthor, StoryCategory}

  @category1 "priv/data/import/story_categories.bsondump"
  @authors1 "priv/data/import/story_authors.bsondump"
  @stories1 "test/support/fixtures/stories.bsondump"

  if File.exists?(@category1) do
    for {f, n} <- [{@category1, 38}, {@authors1, 5029}] do
      test "parse_bsondump #{f}" do
        res = Loader.parse_bsondump unquote(f), fn json, _i ->
          # pp i
          # pp json
          assert %{uid: _, oid: _} = json
        end

        assert res == unquote(n)
      end
    end

    test "parse_bsondump" do
      res = Loader.parse_bsondump @stories1, fn json, i ->
        pp i
        # pp Enum.join(json[:story_body], "\n")
        pp Map.delete(json, :story_body)
        assert %{uid: _, oid: _} = json
      end

      assert res == 3
    end

    test "load_categories" do
      Loader.load_categories(@category1)
      assert Stories.count(StoryCategory) == 38

      obj1 = StoryCategory |> first(:id) |> Repo.one
      pp obj1
    end

    test "load_authors" do
      Loader.load_authors(@authors1)
      assert Stories.count(StoryAuthor) > 5000

      obj1 = StoryAuthor |> first(:id) |> Repo.one
      pp obj1
    end

    test "load_stories" do
      Loader.load_categories(@category1)
      Loader.load_authors(@authors1)

      Loader.load_stories(@stories1)
      assert Stories.count(Story) == 3

      obj1 = Story |> first(:id) |> Repo.one |> Repo.preload([:story_author, :story_categories])
      pp obj1
      assert length(obj1.story_categories) == 1
    end

    test "cache_data" do
      cat1 = story_category_fixture()
      au1 = story_author_fixture()

      res = {cc1, aa1} = Loader.cache_data
      pp res

      assert cc1[cat1.oid] == cat1
      assert aa1[au1.oid] == au1
    end

    test "load_fake_data" do
      res = Loader.load_fake_data(2, 3, 5)
      pp res
      assert Stories.count(StoryCategory) == 2
      assert Stories.count(StoryAuthor) == 3
      assert Stories.count(Story) == 5
    end
  end
end
