defmodule App.Repo.Migrations.AddIsVisibleToCategories do
  use Ecto.Migration

  def change do
    alter table(:story_categories) do
      add :is_visible, :boolean, default: true
    end

    create index(:story_categories, [:is_visible])
  end
end
