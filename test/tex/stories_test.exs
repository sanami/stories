defmodule Tex.StoriesTest do
  use Tex.DataCase

  alias Tex.Stories

  describe "story_categories" do
    alias Tex.Stories.StoryCategory

    import Tex.StoriesFixtures

    @invalid_attrs %{name: nil, uid: nil}

    test "list_story_categories/0 returns all story_categories" do
      story_category = story_category_fixture()
      assert Stories.list_story_categories() == [story_category]
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
  end

  describe "story_authors" do
    alias Tex.Stories.StoryAuthor

    import Tex.StoriesFixtures

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
  end

  describe "stories" do
    alias Tex.Stories.Story

    import Tex.StoriesFixtures

    @invalid_attrs %{story_date: nil, story_excerpt: nil, rating: nil, title: nil, uid: nil}

    test "list_stories/0 returns all stories" do
      story = story_fixture()
      res = Stories.list_stories |> Repo.all
      assert res == [story]
    end

    test "get_story!/1 returns the story with given id" do
      story = story_fixture()
      assert Stories.get_story!(story.id) == story
    end

    test "create_story/1 with valid data creates a story" do
      valid_attrs = %{story_date: ~D[2023-07-04], story_excerpt: "some story_excerpt", story_body: "some story_body", rating: 1, rating_count: 2, title: "some title", uid: 42}

      assert {:ok, %Story{} = story} = Stories.create_story(valid_attrs)
      assert story.story_date == ~D[2023-07-04]
      assert story.story_excerpt == "some story_excerpt"
      assert story.story_body == "some story_body"
      assert story.rating == 1
      assert story.rating_count == 2
      assert story.title == "some title"
      assert story.uid == 42
    end

    test "create_story/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stories.create_story(@invalid_attrs)
    end

    test "set_story_categories" do
      cat1 = story_category_fixture(%{name: "cat1", uid: 1, oid: "1"})
      cat2 = story_category_fixture(%{name: "cat2", uid: 2, oid: "2"})
      story1 = story_fixture()

      res = Stories.set_story_categories(story1, {:ids, [cat1.id, cat2.id]})
      #res = Stories.set_story_categories(story1, {:objects, [cat1, cat2]})
      IO.inspect res

      story11 = Stories.get_story!(story1.id) |> Repo.preload(:story_categories)
      IO.inspect story11
      IO.inspect Enum.sort(story11.story_categories) == Enum.sort([cat1, cat2])

      cats11 = Repo.all(assoc(story11, :story_categories))
      IO.inspect Enum.sort(cats11) == Enum.sort([cat1, cat2])
    end
  end
end
