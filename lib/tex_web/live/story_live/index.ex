defmodule TexWeb.StoryLive.Index do
  use TexWeb, :live_view
  alias Tex.{Repo, Stories}
  require Logger

  @impl true
  def mount(params, session, socket) do
    Logger.debug "---mount #{inspect params} #{inspect session} #{socket.id} #{inspect self()}"

    socket =
      socket
      |> set_stories(params, false)
      |> assign(story_categories: Stories.list_story_categories)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, uri, socket) do
    Logger.debug "---handle_params #{socket.assigns[:live_action]} #{inspect params} #{uri} #{socket.id} #{inspect self()}"

    {:noreply, apply_action(socket, socket.assigns[:live_action], params)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    {:noreply, set_stories(socket, params)}
  end

  @impl true
  def handle_event("set_favorite", %{"id" => id}, socket) do
    story =
      Stories.set_favorite(id)
      |> Repo.preload([:story_author, :story_categories])
    socket = stream_insert(socket, :stories, story)
    {:noreply, socket}
  end

  # Live actions
  defp apply_action(socket, :show, %{"story_id" => story_id}) do
    story = Stories.get_story!(story_id)

    socket
    |> assign(:page_title, story.title)
    |> assign(:story, story)
  end

  defp apply_action(socket, :favorites, params) do
    socket
    |> assign(:page_title, "Избранное")
    |> assign(story: nil, is_favorites: true)
    |> set_stories(params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Рассказы")
    |> assign(story: nil, is_favorites: false)
    |> set_stories(params)
  end

  defp set_stories(socket, params, stream \\ true) do
    Logger.debug "---set_stories #{inspect params}"

    is_favorites = socket.assigns[:is_favorites]
    filter_params =
      params
      |> Map.take(~w[query author_id cat_ids rating page page_size sort sort_dir])
      |> Map.filter(fn {_key, val} -> val && val != "" && val != [] end)

    page =
      Stories.list_stories(filter_params, is_favorites)
      |> Repo.paginate(filter_params)

    author = if filter_params["author_id"], do: Stories.get_story_author!(filter_params["author_id"])

    stories =
      if stream do
        page.entries
        |> Repo.preload([:story_author, :story_categories])
      else
        []
      end

    socket
    |> stream(:stories, stories, reset: true)
    |> assign(author: author, page: page, filter_params: filter_params, filter_form: to_form(filter_params))
  end

  # Helpers
  def favorite?(story) do
    !!story.favorited_at
  end
end
