defmodule Tex.Repo do
  use Ecto.Repo,
    otp_app: :tex,
    adapter: Ecto.Adapters.SQLite3

  use Scrivener, page_size: 10
end
