defmodule AppWeb.SessionController do
  use AppWeb, :controller

  @allowed_session_keys ~w[theme_toggle font_size locale]

  def set(conn, params) do
    params
    |> Map.take(@allowed_session_keys)
    |> Enum.reduce(conn, fn {k, v}, conn ->
      put_session(conn, k, v)
    end)
    |> text("OK")
  end

  def set_locale(conn, %{"locale" => locale, "url" => url}) do
    conn
    |> put_session("locale", locale)
    |> redirect(to: url)
  end
end
