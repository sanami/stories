defmodule App.StoriesTest do
  use App.DataCase
  import App.StoriesFixtures

  alias App.Stories
  alias App.Stories.{Story, StorySearch}

  describe "story_categories" do
    alias App.Stories.StoryCategory

    @invalid_attrs %{name: nil, uid: nil}

    test "list_story_categories" do
      sc1 = story_category_fixture()
      sc2 = story_category_fixture(is_visible: false)

      assert Stories.list_story_categories() == [sc1]
      assert Stories.list_story_categories(false) == [sc1, sc2]
    end

    test "get_story_category!/1 returns the story_category with given id" do
      story_category = story_category_fixture()
      assert Stories.get_story_category!(story_category.id) == story_category
    end

    test "create_story_category/1 with valid data creates a story_category" do
      valid_attrs = %{name: "some name", uid: 42, oid: "42"}

      assert {:ok, %StoryCategory{} = story_category} = Stories.create_story_category(valid_attrs)
      assert story_category.name == "some name"
      assert story_category.uid == 42
      assert story_category.oid == "42"
    end

    test "create_story_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stories.create_story_category(@invalid_attrs)
    end

    test "get_story_categories" do
      cat1 = story_category_fixture(%{name: "cat1", uid: 1, oid: "1"})
      cat2 = story_category_fixture(%{name: "cat2", uid: 2, oid: "2"})

      assert Stories.get_story_categories(["1"]) == [cat1]
      assert Stories.get_story_categories(["1", "2"]) == [cat1, cat2]
    end

    test "count" do
      assert Stories.count(StoryCategory) == 0
      _story_category = story_category_fixture()
      assert Stories.count(StoryCategory) == 1
    end

    test "set_visible" do
      sc1 = story_category_fixture()
      assert sc1.is_visible

      sc1 = Stories.set_visible(sc1, false)
      refute sc1.is_visible
    end
  end

  describe "story_authors" do
    alias App.Stories.StoryAuthor

    @invalid_attrs %{name: nil, uid: nil}

    test "list_story_authors/0 returns all story_authors" do
      story_author = story_author_fixture()
      assert Stories.list_story_authors() == [story_author]
    end

    test "get_story_author!/1 returns the story_author with given id" do
      story_author = story_author_fixture()
      assert Stories.get_story_author!(story_author.id) == story_author
    end

    test "create_story_author/1 with valid data creates a story_author" do
      valid_attrs = %{name: "some name", uid: 42, oid: "42"}

      assert {:ok, %StoryAuthor{} = story_author} = Stories.create_story_author(valid_attrs)
      assert story_author.name == "some name"
      assert story_author.uid == 42
      assert story_author.oid == "42"
    end

    test "create_story_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stories.create_story_author(@invalid_attrs)
    end

    test "set_favorite_author" do
      u1 = story_author_fixture()
      refute Stories.favorite?(u1)

      Stories.set_favorite_author(u1.id)
      u11 = Repo.reload u1
      assert Stories.favorite?(u11)
    end
  end

  describe "stories" do
    @invalid_attrs %{story_date: nil, story_excerpt: nil, rating: nil, title: nil, uid: nil}

    test "list_stories/0 returns all stories" do
      cat1 = story_category_fixture()

      story_fixture(cat1, %{uid1: 1})
      story_fixture(cat1, %{uid1: 2})

      res = Stories.list_stories |> Repo.all
      assert length(res) == 2
    end

    test "get_story!/1 returns the story with given id" do
      story = story_fixture()
      assert Stories.get_story!(story.id) == story
    end

    test "create_story/1 with valid data creates a story" do
      valid_attrs = %{story_date: ~D[2023-07-04], story_excerpt: "some story_excerpt", story_body: "some story_body", rating: 1, rating_count: 2, title: "some title", uid: 42}

      {:ok, story} = Stories.create_story(valid_attrs)

      assert story.story_date == ~D[2023-07-04]
      assert story.story_excerpt == "some story_excerpt"
      assert story.story_body == "some story_body"
      assert story.rating == 1
      assert story.rating_count == 2
      assert story.title == "some title"
      assert story.uid == 42

      assert File.exists?(Stories.story_file(story))
    end

    test "create_story/1 with invalid data returns error changeset" do
      res = Stories.create_story(@invalid_attrs)
      pp res
      assert {:error, :story, %Ecto.Changeset{}, _} = res
    end

    test "delete_story" do
      s1 = story_fixture()
      Stories.delete_story(s1)

      refute Repo.get(Story, s1.id)
      assert Stories.count(Story) == 0
      assert Stories.count(StorySearch) == 0
    end

    test "set_story_categories" do
      cat1 = story_category_fixture(%{name: "cat1", uid: 1, oid: "1"})
      cat2 = story_category_fixture(%{name: "cat2", uid: 2, oid: "2"})
      story1 = story_fixture()

      res = Stories.set_story_categories(story1, {:ids, [cat1.id, cat2.id]})
      #res = Stories.set_story_categories(story1, {:objects, [cat1, cat2]})
      pp res

      story11 = Stories.get_story!(story1.id) |> Repo.preload(:story_categories)
      pp story11
      pp Enum.sort(story11.story_categories) == Enum.sort([cat1, cat2])

      cats11 = Repo.all(assoc(story11, :story_categories))
      pp Enum.sort(cats11) == Enum.sort([cat1, cat2])
    end

    test "load_story_body" do
      s1 = Repo.reload(story_fixture())
      pp s1
      assert s1.story_body == nil

      s2 = Stories.load_story_body(s1)
      refute s2.story_body == nil

      s3 = Stories.load_story_body(%Story{id: nil})
      assert s3.story_body == :not_found
    end

    test "story_fixture" do
      s1 = story_fixture(%{id: 11})
      s1 = Repo.reload(s1)
      pp s1
      assert s1.id == 11

      # search
      ss1 = Repo.get!(StorySearch, s1.id)
      pp ss1
      assert ss1.title == s1.title

      # dup id
      assert_raise Ecto.ConstraintError, fn -> story_fixture(%{id: 11}) end
    end

    test "search" do
      s1 = story_fixture(%{id: 11})
      pp Repo.all(Story)
      pp Repo.all(StorySearch)

      # search
      res = Stories.search("story title")
      pp res
      assert length(res) == 1

      assert length(Stories.search("story+body")) == 1

      # delete
      Repo.delete s1
      assert Repo.all(Story) == []
      assert Repo.all(StorySearch) == []
    end

    test "set_favorite_story" do
      s1 = story_fixture()
      refute Stories.favorite?(s1)

      Stories.set_favorite_story(s1.id)
      s11 = Repo.reload s1
      assert Stories.favorite?(s11)
    end
  end
end
