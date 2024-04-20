defmodule TexWeb.Components.Helpers do
  use TexWeb, :html

  embed_templates "helpers/*"

  attr :filter_form, :map, required: true
  attr :author, :any
  attr :story_categories, :any
  attr :page, :any
  def story_filter_form(assigns)

  attr :page, :map, required: true
  attr :rest, :global, default: %{class: "my-4"}
  def pagination(assigns)

  attr :story, :map
  def story_details(assigns) do
    ~H"""
    <span class="mt-1 text-sm"><%= @story.story_date %></span>
    <span :if={@story.rating} class="whitespace-nowrap  text-sm  w-min">
      <span class="badge"><%= @story.rating %></span> <%= @story.rating_count %>
    </span>
    """
  end
end
