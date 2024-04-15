defmodule Examples.Query03Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    Repo.insert_all("artists", [[name: "Bill Evans"], [name: "Billy Bob"]])
    :ok
  end

  test "dynamic value in the where clause" do
    name = "Bill Evans"
    query = from("artists", select: [:name], where: [name: ^name])
    assert Repo.all(query) == [%{name: "Bill Evans"}]
  end

  test "expression in the where clause" do
    query = from("artists", select: [:name], where: [name: ^("Bill" <> " " <> "Evans")])
    assert Repo.all(query) == [%{name: "Bill Evans"}]
  end
end
