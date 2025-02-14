defmodule AppWeb.SessionController do
  use AppWeb, :controller

  def set(conn, %{"theme_toggle" => theme_toggle}), do: store_session(conn, :theme_toggle, theme_toggle)

  defp store_session(conn, key, value) do
    conn
    |> put_session(key, value)
    |> json("OK")
  end
end
