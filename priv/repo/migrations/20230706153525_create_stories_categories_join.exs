defmodule Tex.Repo.Migrations.CreateStoriesCategoriesJoin do
  use Ecto.Migration

  def change do
    create table(:stories_categories_join, primary_key: false) do
      add :story_id, references(:stories, on_delete: :delete_all)
      add :story_category_id, references(:story_categories, on_delete: :delete_all)
    end

    create index(:stories_categories_join, [:story_id])
    create index(:stories_categories_join, [:story_category_id])
    create index(:stories_categories_join, [:story_id, :story_category_id], unique: true)
  end
end
