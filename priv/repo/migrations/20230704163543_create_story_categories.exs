defmodule Tex.Repo.Migrations.CreateStoryCategories do
  use Ecto.Migration

  def change do
    create table(:story_categories) do
      add :uid, :integer
      add :oid, :string, null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:story_categories, [:uid], unique: true)
    create index(:story_categories, [:oid], unique: true)
    create index(:story_categories, [:name], unique: true)
  end
end
