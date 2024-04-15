defmodule Tex.StoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tex.Stories` context.
  """

  @doc """
  Generate a story_category.
  """
  def story_category_fixture(attrs \\ %{}) do
    {:ok, story_category} =
      attrs
      |> Enum.into(%{
        name: "cat1",
        uid: 42,
        oid: "42"
      })
      |> Tex.Stories.create_story_category()

    story_category
  end

  @doc """
  Generate a story_author.
  """
  def story_author_fixture(attrs \\ %{}) do
    {:ok, story_author} =
      attrs
      |> Enum.into(%{
        name: "story1",
        uid: 42,
        oid: "42"
      })
      |> Tex.Stories.create_story_author()

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
        story_excerpt: "some story_excerpt",
        story_body: "some story_body",
        rating: 1,
        rating_count: 2,
        title: "some title",
        uid: 42
      })
      |> Tex.Stories.create_story()

    story
  end
end
