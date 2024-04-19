defmodule Examples.Query07Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    Repo.insert_all("artists", [[name: "ONe"], [name: "tWo"]])
    :ok
  end

  test "sql fragments" do
    query =
      from artist in "artists",
        order_by: [:name],
        select: %{name: fragment("lower(?)", artist.name)}

    assert Repo.all(query) == [%{name: "one"}, %{name: "two"}]
  end

  describe "extending ecto query api with macros for sql fragments" do
    defmacro lower(arg) do
      quote do: fragment("lower(?)", unquote(arg))
    end

    test "lower" do
      query =
        from artist in "artists",
          select: [:name],
          where: lower(artist.name) == "two"

      assert Repo.all(query) == [%{name: "tWo"}]
    end
  end
end
