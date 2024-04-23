defmodule TexWeb.PageController do
  use TexWeb, :controller

  def home(conn, _params) do
#    render(conn, :home)
    redirect(conn, to: ~p"/test")
  end

  def test(conn, params) do
    test_params = params["test"] || %{}
    data = %{attr1: "hello", attr2: "world"}

    types = %{
      attr1: :string,
      attr2: :string,
      attr3: :integer,
      attr4: :boolean,
      attr5: :integer,
      attr6: :any,
    }

    changeset =
      {data, types}
      |> Ecto.Changeset.cast(test_params, Map.keys(types))
      |> Ecto.Changeset.validate_required(Map.keys(types))
    dbg changeset

    changeset =
      if changeset.valid? do
        changeset
      else
        %{changeset | action: "invalid"}
      end

    tests = [
      %{
        attr1: "attr1",
        attr2: "attr2",
        attr3: "attr3",
      },
      %{
        attr1: "attr11",
        attr2: "attr22",
        attr3: "attr33",
      },
      %{
        attr1: "attr111",
        attr2: "attr222",
        attr3: "attr333",
      },
    ]

    conn =
      conn
      |> put_flash(:info, "Info")
#      |> put_flash(:error, "Error")

    render(conn, :test, changeset: changeset, tests: tests)
  end
end
