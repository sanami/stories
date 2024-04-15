# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tex.Repo.insert!(%Tex.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

lev = Logger.level
Logger.configure level: :info

Tex.Stories.Loader.load_categories("priv/data/story_categories.bsondump")
Tex.Stories.Loader.load_authors("priv/data/story_authors.bsondump")
Tex.Stories.Loader.load_stories("priv/data/stories.bsondump")

Logger.configure lev
