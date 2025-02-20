defmodule AppWeb.StoryLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.StoriesFixtures

  defp create_story(_) do
    cat = story_category_fixture()
    story = story_fixture(cat, %{})

    %{cat: cat, story: story}
  end

  defp create_20_stories(_) do
    cat = story_category_fixture()

    for n <- 1..20, into: %{cat: cat} do
      s = story_fixture(cat, %{})
      {:"story#{n}", s}
    end
  end

  describe "/stories" do
    setup [:create_story]

    test "lists all stories", %{conn: conn, story: story} do
      {:ok, _live, html} = live(conn, ~p"/story")

      assert html =~ story.title
    end
  end

  test "/story/favorites", %{conn: conn} do
    cat = story_category_fixture()
    s1 = story_fixture(cat, %{favorited_at: DateTime.now!("Etc/UTC")})
    s2 = story_fixture(cat, %{})

    {:ok, _view, html} = live(conn, ~p"/story/favorites")

    assert html =~ s1.title
    refute html =~ s2.title
  end

  describe "filter" do
    setup [:create_20_stories]

    test "reset", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/story")

      view
      |> element("#reset")
      |> render_click()

      assert_push_event view, "set_page_url", %{}
    end

    test "page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/story")

      view
      |> element("#top_pagination .next_page")
      |> render_click()

      assert_push_event view, "set_page_url", %{}
      # open_browser(view)

      assert_raise ArgumentError, fn ->
        view
        |> element("#top_pagination .next_page")
        |> render_click()
      end
    end
  end
end
