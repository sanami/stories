defmodule App.Stories.Story do
  use Ecto.Schema
  import Ecto.Changeset

  alias App.Stories

  schema "stories" do
    field :story_date, :date
    field :story_excerpt, :string
    field :story_body, :string, virtual: true
    field :rating, :float
    field :rating_count, :integer
    field :title, :string
    field :uid, :integer
    field :favorited_at, :utc_datetime

    belongs_to :story_author, Stories.StoryAuthor
    many_to_many :story_categories, Stories.StoryCategory, join_through: "stories_categories_join", unique: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(story, attrs) do
    story
    |> cast(attrs, [:id, :uid, :title, :story_date, :story_excerpt, :story_body, :rating, :rating_count, :story_author_id, :favorited_at])
    |> validate_required([:uid, :title, :story_date, :story_excerpt, :story_body])
  end

  def set_favorite(story, favorited_at) do
    change(story, favorited_at: favorited_at)
  end
end
