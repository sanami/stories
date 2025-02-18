defmodule AppWeb.InitLocale do
  use Phoenix.VerifiedRoutes, endpoint: AppWeb.Endpoint, router: AppWeb.Router
  import Phoenix.LiveView

  require Logger

  def on_mount(:default, _params, session, socket) do
    locale = session["locale"]
    if is_binary(locale) do
      Logger.debug "---locale #{locale}"
      Gettext.put_locale(AppWeb.Gettext, locale)
    end

    socket =
      socket
      |> attach_hook(:locale, :handle_event, &handle_event_locale/3)

    {:cont, socket}
  end

  defp handle_event_locale("set_locale", %{"locale" => locale}, socket) do
    %{path: path, query: query} = socket.assigns.current_uri
    url = %URI{path: path, query: query} |> URI.to_string

    socket =
      socket
      |> redirect(to: ~p"/session/set_locale?#{[locale: locale, url: url]}")

    {:halt, socket}
  end

  defp handle_event_locale(_event, _params, socket) do
    {:cont, socket}
  end
end
