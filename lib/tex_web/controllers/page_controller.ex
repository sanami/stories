defmodule TexWeb.PageController do
  use TexWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
