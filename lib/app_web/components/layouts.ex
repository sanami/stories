defmodule AppWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use AppWeb, :controller` and
  `use AppWeb, :live_view`.
  """
  use AppWeb, :html

  embed_templates "layouts/*"
  embed_templates "helpers/*"

  attr :filter_form, :map, required: true
  attr :author_options, :list
  attr :story_categories, :list
  attr :page, :any
  def story_filter_form(assigns)
end
