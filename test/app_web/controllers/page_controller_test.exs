defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) =~ ~p"/story"
  end
end
