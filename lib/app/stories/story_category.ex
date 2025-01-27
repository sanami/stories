defmodule App.Stories.StoryCategory do
  use Ecto.Schema
  import Ecto.Changeset

  alias App.Stories

  schema "story_categories" do
    field :name, :string
    field :uid, :integer
    field :oid, :string

    many_to_many :stories, Stories.Story, join_through: "stories_categories_join", unique: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(story_category, attrs) do
    story_category
    |> cast(attrs, [:uid, :oid, :name])
    |> validate_required([:uid, :oid, :name])
  end
end
