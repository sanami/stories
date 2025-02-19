defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :home

    post "/session", SessionController, :set
    get "/session/set_locale", SessionController, :set_locale

    live_session :default, on_mount: [AppWeb.InitAssigns, AppWeb.InitLocale] do
      live "/story", StoryLive.Index, :index
      live "/story/favorites", StoryLive.Index, :favorites
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
