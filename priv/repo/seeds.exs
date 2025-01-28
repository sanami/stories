# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias App.Stories.Loader

level = Logger.level
Logger.configure level: :info

sc_file = "priv/db/import/story_categories.bsondump"
sa_file = "priv/db/import/story_authors.bsondump"
st_file = "priv/db/import/stories.bsondump"

if Enum.all?([sc_file, sa_file, st_file], &File.exists?/1) do
  Loader.load_categories(sc_file)
  Loader.load_authors(sa_file)
  Loader.load_stories(st_file)
else
  IO.puts "Import files not found. Seeding fake data"
  Loader.load_fake_data(10, 100, 1000)
end

Logger.configure level: level
