defmodule Tex.Stories.Document do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true, source: :rowid}
  schema "documents" do
    field :title, :string
    field :author, :string
    field :body, :string
    field :story_id, :integer
    field :rank, :float, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
#    |> cast(attrs, [:title, :body, :author, :story_id])
    |> cast(attrs, [:title, :body, :story_id])
    |> validate_required([:title, :body, :story_id])
  end
end
