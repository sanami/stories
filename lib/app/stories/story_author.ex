defmodule App.Stories.StoryAuthor do
  use Ecto.Schema
  import Ecto.Changeset

  alias App.Stories

  schema "story_authors" do
    field :name, :string
    field :uid, :integer
    field :oid, :string
    field :favorited_at, :utc_datetime

    has_many :stories, Stories.Story

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(story_author, attrs) do
    story_author
    |> cast(attrs, [:uid, :oid, :name, :favorited_at])
    |> validate_required([:uid, :oid, :name])
  end
end
