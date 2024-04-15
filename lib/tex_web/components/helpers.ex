defmodule TexWeb.Components.Helpers do
  use Phoenix.Component

  embed_templates "helpers/*"

  attr :page, :map, required: true
  attr :path, :any
  attr :rest, :global, default: %{}
  def pagination(assigns)

  attr :story, :map
  def story_details(assigns) do
    ~H"""
    <span class="mt-1 text-gray-500 text-sm"><%= @story.story_date %></span>
    <span :if={@story.rating} class="whitespace-nowrap  text-sm  w-min">
      <span class="px-2.5 py-0.5 rounded-full bg-purple-100 text-purple-700"><%= @story.rating %></span> <%= @story.rating_count %>
    </span>
    """
  end
end