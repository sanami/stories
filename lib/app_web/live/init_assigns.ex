defmodule AppWeb.InitAssigns do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    socket =
      attach_hook(socket, :set_current_uri, :handle_params, fn _end_params, uri, socket ->
        {:cont, assign(socket, current_uri: URI.parse(uri))}
      end)

    {:cont, socket}
  end
end
