defmodule Examples.Query02Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    Repo.insert_all("artists", [[name: "Bill Evans"], [name: "Billy Bob"]])
    :ok
  end

  test "static value in the where clause" do
    query = from("artists", select: [:name], where: [name: "Bill Evans"])
    assert Repo.all(query) == [%{name: "Bill Evans"}]
  end
end
