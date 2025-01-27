defmodule App.Stories.StorySearch do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Stories.{StorySearch, Story}

  @primary_key {:id, :id, autogenerate: true, source: :rowid}
  schema "story_search" do
    field :title, :string
    field :body, :string
    field :rank, :float, virtual: true
  end

  @doc false
  def changeset(%Story{} = story) do
    %StorySearch{}
    |> change(%{id: story.id, title: story.title, body: story.story_body})
    |> validate_required([:id, :title, :body])
  end
end
