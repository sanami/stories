defmodule TexWeb.PageHTML do
  use TexWeb, :html

  embed_templates "page_html/*"

  @doc """
  Renders a test form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def test_form(assigns)
end
