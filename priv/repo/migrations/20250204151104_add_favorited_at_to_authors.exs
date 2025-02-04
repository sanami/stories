defmodule App.Repo.Migrations.AddFavoritedAtToAuthors do
  use Ecto.Migration

  def change do
    alter table(:story_authors) do
      add :favorited_at, :utc_datetime
    end

    create index(:story_authors, [:favorited_at])
  end
end
