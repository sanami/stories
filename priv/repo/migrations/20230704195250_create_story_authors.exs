defmodule Tex.Repo.Migrations.CreateStoryAuthors do
  use Ecto.Migration

  def change do
    create table(:story_authors) do
      add :uid, :integer
      add :oid, :string, null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:story_authors, [:uid], unique: true)
    create index(:story_authors, [:oid], unique: true)
    create index(:story_authors, [:name], unique: true)
  end
end
