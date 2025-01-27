defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET /test", %{conn: conn} do
    conn = get(conn, ~p"/test")
    assert html_response(conn, 200) =~ "test"
  end
end
