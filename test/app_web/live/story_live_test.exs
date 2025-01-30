defmodule AppWeb.StoryLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.StoriesFixtures

  defp create_story(_) do
    cat = story_category_fixture()
    story = story_fixture(cat, %{})

    %{cat: cat, story: story}
  end

  describe "Index" do
    setup [:create_story]

    test "lists all stories", %{conn: conn, story: story} do
      {:ok, _index_live, html} = live(conn, ~p"/story")

      assert html =~ story.title
    end
  end
end
