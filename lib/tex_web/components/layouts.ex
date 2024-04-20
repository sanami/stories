defmodule TexWeb.Layouts do
  use TexWeb, :html
  import TexWeb.Components.Helpers

  embed_templates "layouts/*"
end
