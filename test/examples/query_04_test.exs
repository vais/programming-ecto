defmodule Examples.Query04Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    {2, [%{id: id}, %{}]} =
      Repo.insert_all("artists", [[name: "Bill Evans"], [name: "Billy Bob"]], returning: [:id])

    %{id: id}
  end

  test "dynamic value of a matching data type", %{id: id} do
    query = from("artists", select: [:name], where: [id: ^id])
    assert Repo.all(query) == [%{name: "Bill Evans"}]
  end

  test "dynamic value of a different data type", %{id: id} do
    id = to_string(id)

    query = from("artists", select: [:name], where: [id: ^id])

    assert_raise DBConnection.EncodeError, ~r"expected an integer", fn ->
      Repo.all(query)
    end

    query = from("artists", select: [:name], where: [id: type(^id, :integer)])
    assert Repo.all(query) == [%{name: "Bill Evans"}]
  end
end
