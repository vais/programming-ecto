defmodule Examples.Query06Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    Repo.insert_all(
      "artists",
      [
        [name: "alive"],
        [name: "dead", death_date: ~D"2015-01-13"]
      ]
    )

    :ok
  end

  test "query expressions" do
    query =
      from "artists",
        select: [:name],
        order_by: [:name]

    assert Repo.all(query) == [%{name: "alive"}, %{name: "dead"}]

    query =
      from artist in "artists",
        where: is_nil(artist.death_date),
        select: [:name],
        order_by: [:name]

    assert Repo.all(query) == [%{name: "alive"}]

    query =
      from artist in "artists",
        where: not is_nil(artist.death_date),
        select: [:name],
        order_by: [:name]

    assert Repo.all(query) == [%{name: "dead"}]

    query =
      from artist in "artists",
        where: artist.death_date > ago(3, "month"),
        select: [:name],
        order_by: [:name]

    assert Repo.all(query) == []

    query =
      from artist in "artists",
        where: ilike(artist.name, "%IVE"),
        select: [:name],
        order_by: [:name]

    assert Repo.all(query) == [%{name: "alive"}]
  end
end
