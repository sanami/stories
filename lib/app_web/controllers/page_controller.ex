defmodule AppWeb.PageController do
  use AppWeb, :controller

  def home(conn, _params) do
    # render(conn, :home)
    redirect(conn, to: ~p"/story")
  end
end
