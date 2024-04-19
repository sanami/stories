defmodule Tex.Repo.Migrations.CreateStorySearch do
  use Ecto.Migration

  def up do
    execute("""
      CREATE VIRTUAL TABLE story_search USING fts5(
        title,
        body,
        content='stories',
        content_rowid='id'
      );
    """)

#    execute("""
#      CREATE TRIGGER story_search_ai AFTER INSERT ON stories BEGIN
#        INSERT INTO story_search(rowid, title) VALUES (new.id, new.title);
#      END;
#    """)
#
#    execute("""
#      CREATE TRIGGER story_search_ad AFTER DELETE ON stories BEGIN
#        INSERT INTO story_search(story_search, rowid, title) VALUES('delete', old.id, old.title);
#      END;
#    """)
#
#    execute("""
#      CREATE TRIGGER story_search_au AFTER UPDATE ON stories BEGIN
#        INSERT INTO story_search(story_search, rowid, title) VALUES('delete', old.id, old.title);
#        INSERT INTO story_search(rowid, title) VALUES (new.id, new.title);
#      END;
#    """)

  end

  def down do
#    execute("DROP TRIGGER IF EXISTS story_search_ai;")
#    execute("DROP TRIGGER IF EXISTS story_search_ad;")
#    execute("DROP TRIGGER IF EXISTS story_search_au;")

    execute("""
      DROP TABLE story_search;
    """)
  end
end
