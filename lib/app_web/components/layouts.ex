defmodule AppWeb.Layouts do
  use AppWeb, :html
  import AppWeb.Components.Helpers

  embed_templates "layouts/*"
end
