defmodule AppWeb.SessionControllerTest do
  use AppWeb.ConnCase

  test "POST /session", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{"font_size" => 1})
      |> post(~p"/session", %{"font_size" => 2, "theme_toggle" => true})

    assert conn.resp_body == "OK"
    assert %{"font_size" => 2, "theme_toggle" => true} = get_session(conn)
  end

  test "GET /session/set_locale", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{"locale" => nil})
      |> get(~p"/session/set_locale", %{"locale" => "en", "url" => "/story"})

    assert redirected_to(conn) =~ ~p"/story"
    assert %{"locale" => "en"} = get_session(conn)
  end
end
