defmodule AppWeb.Helpers do
  def current_locale?(locale) do
    Gettext.get_locale(AppWeb.Gettext) == locale
  end

  # Settings
  def settings_params(filter_params) do
    Map.take(filter_params || %{}, ~w[page_size sort sort_dir story_id])
  end

  # Settings + navigate
  def build_params(filter_params, params \\ %{}) do
    Enum.into(params, settings_params(filter_params))
  end
end
