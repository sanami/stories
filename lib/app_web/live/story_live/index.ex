defmodule AppWeb.StoryLive.Index do
  use AppWeb, :live_view
  import AppWeb.Components.Helpers
  alias App.{Repo, Stories}
  require Logger

  @impl true
  def mount(params, session, socket) do
    Logger.debug "---mount #{inspect params} #{inspect session}"

    socket =
      socket
      |> set_stories(params, false)
      |> assign(story_categories: Stories.list_story_categories)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, uri, socket) do
    Logger.debug "---handle_params #{socket.assigns[:live_action]} #{inspect params} #{uri}"
    {:noreply, apply_action(socket, socket.assigns[:live_action], params)}
  end

  # Live actions
  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Рассказы")
    |> assign(is_favorites: false)
    |> set_stories(params)
  end

  defp apply_action(socket, :favorites, params) do
    socket
    |> assign(:page_title, "Избранное")
    |> assign(is_favorites: true)
    |> set_stories(params)
  end

  # Events
  @impl true
  def handle_event("filter", params, socket) do
    {:noreply, set_stories(socket, params)}
  end

  @impl true
  def handle_event("set_favorite", %{"id" => story_id}, socket) do
    story =
      Stories.set_favorite(story_id)
      |> Repo.preload([:story_author, :story_categories])

    socket =
      if socket.assigns[:current_story] && socket.assigns.current_story.id == story.id do
        current_story = %{socket.assigns.current_story | favorited_at: story.favorited_at}
        assign(socket, :current_story, current_story)
      else
        socket
      end

    {:noreply, update_existing_story(socket, story)}
  end

  @impl true
  def handle_event("set_current_story", %{"id" => story_id}, socket) do
    story_id = String.to_integer(story_id)
    {:noreply, set_current_story(socket, story_id)}
  end

  @impl true
  def handle_event("set_page", %{"page" => page}, socket) do
    filter_params = Map.merge(socket.assigns[:filter_params], %{"page" => page})
    {:noreply, set_stories(socket, filter_params)}
  end

  defp set_stories(socket, params, stream \\ true) do
    Logger.debug "---set_stories #{inspect params}"

    is_favorites = socket.assigns[:is_favorites]
    filter_params =
      params
      |> Map.take(~w[query author_id cat_ids rating page page_size sort sort_dir])
      |> Map.filter(fn {_key, val} -> val && val != "" && val != [] end)
      |> Map.put_new("page", 1)

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

    story_ids = Enum.map(stories, &(&1.id))

    socket
    |> stream(:stories, stories, reset: true)
    |> assign(:exiting_story_ids, story_ids)
    |> assign(author: author, page: page, filter_params: filter_params, filter_form: to_form(filter_params))
  end

  defp set_current_story(socket, story_id) do
    prev_story = socket.assigns[:current_story]

    if !prev_story || prev_story.id != story_id do
      story =
        Stories.get_story!(story_id)
        |> Repo.preload([:story_author, :story_categories])

      socket
      |> assign(:current_story, story)
      |> update_existing_story(story)
      |> update_existing_story(prev_story)
    else
      socket
    end
  end

  defp update_existing_story(socket, story) do
    story_ids = socket.assigns[:exiting_story_ids]
    if story && story_ids && Enum.any?(story_ids, &(&1 == story.id)) do
      stream_insert(socket, :stories, story)
    else
      socket
    end
  end

  # Helpers
  defp favorite?(story) do
    !!story.favorited_at
  end

  defp current_story_style(assigns, story) do
    if assigns[:current_story] && assigns[:current_story].id == story.id do
      "bg-base-300"
    end
  end
end
