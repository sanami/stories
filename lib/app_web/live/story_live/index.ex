defmodule AppWeb.StoryLive.Index do
  use AppWeb, :live_view
  require Logger

  alias App.{Repo, Stories}

  embed_templates "helpers/*"

  @impl true
  def mount(params, session, socket) do
    Logger.debug "---mount #{inspect params} #{inspect session}"

    socket =
      socket
      |> assign(font_size: 2)
      |> assign(story_categories: Stories.list_story_categories)
      |> assign(filter_params: %{})

    {:ok, socket}
  end

  @impl true
  def handle_params(params, uri, socket) do
    Logger.debug "---handle_params #{socket.assigns[:live_action]} #{inspect params} #{uri}"

    socket =
      socket
      |> assign(:current_uri, URI.parse(uri))
      |> apply_action(socket.assigns[:live_action], params)
      |> set_current_story(params["story_id"])

    {:noreply, socket}
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
    {:noreply, set_stories(socket, params, true)}
  end

  @impl true
  def handle_event("set_favorite_story", %{"id" => story_id}, socket) do
    story =
      Stories.set_favorite_story(story_id)
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
  def handle_event("set_favorite_author", %{"id" => author_id}, socket) do
    Stories.set_favorite_author(author_id)
    {:noreply, set_stories(socket, socket.assigns.filter_params)}
  end

  @impl true
  def handle_event("set_current_story", %{"id" => story_id}, socket) do
    story_id = String.to_integer(story_id)
    {:noreply, set_current_story(socket, story_id)}
  end

  @impl true
  def handle_event("set_page", %{"page" => page}, socket) do
    filter_params = Map.merge(socket.assigns.filter_params, %{"page" => page})
    {:noreply, set_stories(socket, filter_params)}
  end

  @impl true
  def handle_event("set_font_size", %{"size" => size}, socket) do
    size = String.to_integer(size)
    font_size = socket.assigns.font_size + size

    font_size = if font_size < prose_font_size_min(), do: prose_font_size_min(), else: font_size
    font_size = if font_size > prose_font_size_max(), do: prose_font_size_max(), else: font_size

    {:noreply, assign(socket, :font_size, font_size)}
  end

  defp set_stories(socket, params, reset_page \\ false) do
    Logger.debug "---set_stories #{inspect params}"

    is_favorites = socket.assigns[:is_favorites]
    filter_params =
      socket.assigns.filter_params
      |> Map.merge(params)
      |> Map.take(~w[query author_id cat_ids rating page page_size sort sort_dir story_id])
      |> Map.filter(fn {_key, val} -> val && val != "" && val != [] end)
      |> then(fn params ->
        if reset_page, do: Map.drop(params, ["page"]), else: params
      end)

    page =
      Stories.list_stories(filter_params, is_favorites)
      |> Repo.paginate(filter_params)

    author = if filter_params["author_id"], do: Stories.get_story_author!(filter_params["author_id"])

    stories =
      page.entries
      |> Repo.preload([:story_author, :story_categories])

    story_ids = Enum.map(stories, &(&1.id))

    socket
    |> stream(:stories, stories, reset: true)
    |> assign(:exiting_story_ids, story_ids)
    |> assign(page: page, filter_params: filter_params, filter_form: to_form(filter_params))
    |> assign(author: author, author_options: Stories.author_options(author))
    |> push_event("set_page_url", %{url: current_url(socket, filter_params)})
  end

  defp current_url(socket, params) do
    current_uri = socket.assigns[:current_uri]
    if current_uri do
      %{current_uri | query: Plug.Conn.Query.encode(params)}
      |> URI.to_string
    end
  end

  defp set_current_story(socket, nil), do: socket

  defp set_current_story(socket, story_id) when is_binary(story_id) do
    set_current_story(socket, String.to_integer(story_id))
  rescue
    ArgumentError ->
      socket
  end

  defp set_current_story(socket, story_id) do
    prev_story = socket.assigns[:current_story]

    if !prev_story || prev_story.id != story_id do
      story =
        Stories.get_story!(story_id)
        |> Repo.preload([:story_author, :story_categories])

      filter_params = Map.merge(socket.assigns.filter_params, %{"story_id" => story_id})

      socket
      |> assign(:current_story, story)
      |> update_existing_story(story)
      |> update_existing_story(prev_story)
      |> push_event("reset_scroll", %{element: "#story_viewer"})
      |> push_event("set_page_url", %{url: current_url(socket, filter_params)})
      |> assign(:page_title, story.title)
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
  defp current_story_style(assigns, story) do
    if assigns[:current_story] && assigns[:current_story].id == story.id do
      "bg-base-300"
    end
  end

  defp prose_font_size_min, do: 0
  defp prose_font_size_max, do: 4

  defp prose_font_size(font_size) do
    class = %{
      0 => "prose-sm",
      1 => "prose-base",
      2 => "prose-lg",
      3 => "prose-xl",
      4 => "prose-2xl"
    }

    class[font_size]
  end

  attr :page, :map, required: true
  attr :rest, :global, default: %{class: "my-4"}
  def pagination(assigns)

  attr :story, :map
  def story_details(assigns)
end
