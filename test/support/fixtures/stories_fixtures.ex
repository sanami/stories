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
  def story_fixture(attrs \\ %{}) do
    {:ok, story} =
      attrs
      |> Enum.into(%{
        story_date: ~D[2023-07-04],
        story_excerpt: "story excerpt",
        story_body: "story body",
        rating: 1,
        rating_count: 2,
        title: "story title",
        uid: seqn()
      })
      |> App.Stories.create_story()

    story
  end
end
