defmodule Tex.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    execute("""
      CREATE VIRTUAL TABLE documents USING fts5(
        updated_at UNINDEXED,
        inserted_at UNINDEXED,
        story_id UNINDEXED,
        title,
        author,
        body
      );
      """,
      """
      DROP TABLE documents;
      """
    )
  end
end
