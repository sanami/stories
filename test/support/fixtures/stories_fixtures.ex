defmodule App.StoriesFixtures do
  import App.TestHelpers

  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Stories` context.
  """

  @doc """
  Generate a story_category.
  """
  def story_category_fixture(attrs \\ %{}) do
    {:ok, story_category} =
      attrs
      |> Enum.into(%{
        name: seqs("cat "),
        uid: seqn(),
        oid: seqs("oid")
      })
      |> App.Stories.create_story_category()

    story_category
  end

  @doc """
  Generate a story_author.
  """
  def story_author_fixture(attrs \\ %{}) do
    {:ok, story_author} =
      attrs
      |> Enum.into(%{
        name: seqs("author "),
        uid: seqn(),
        oid: seqs("oid")
      })
      |> App.Stories.create_story_author()

    story_author
  end

  @doc """
  Generate a story.
  """
  def story_fixture(%App.Stories.StoryCategory{} = cat, attrs) do
    story = story_fixture(attrs)
    App.Stories.set_story_categories(story, {:ids, [cat.id]})

    story
  end

  def story_fixture(attrs \\ %{}) do
    {:ok, story} =
      attrs
      |> Enum.into(%{
        story_date: ~D[2023-07-04],
        story_excerpt: "story excerpt",
        story_body: "story body",
        rating: 5,
        rating_count: 7,
        title: seqs("story title [", "]"),
        uid: seqn()
      })
      |> App.Stories.create_story()

    story
  end
end
