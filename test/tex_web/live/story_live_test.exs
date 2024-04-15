defmodule TexWeb.StoryLiveTest do
  use TexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tex.StoriesFixtures

  defp create_story(_) do
    story = story_fixture()
    %{story: story}
  end

  describe "Index" do
    setup [:create_story]

    test "lists all stories", %{conn: conn, story: story} do
      {:ok, _index_live, html} = live(conn, ~p"/story")

      assert html =~ story.title
    end
  end
end
