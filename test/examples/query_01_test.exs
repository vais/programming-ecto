defmodule Examples.Query01Test do
  use MusicDB.DataCase, async: true

  alias Ecto.Query
  alias MusicDB.Repo

  import Query

  describe "keyword vs macro syntax" do
    setup do
      {1, [%{id: album_id}]} =
        Repo.insert_all(
          "albums",
          [
            [
              title: "album title",
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            ]
          ],
          returning: [:id]
        )

      {3, [%{id: _track1_id}, %{id: track2_id}, %{id: track3_id}]} =
        Repo.insert_all(
          "tracks",
          [
            [
              album_id: album_id,
              title: "track 1",
              index: 1,
              duration: 899,
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            ],
            [
              album_id: album_id,
              title: "track 2",
              index: 2,
              duration: 901,
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            ],
            [
              album_id: album_id,
              title: "track 3",
              index: 3,
              duration: 900,
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            ]
          ],
          returning: [:id]
        )

      %{
        expected: [
          %{id: track2_id, title: "track 2", album: "album title"},
          %{id: track3_id, title: "track 3", album: "album title"}
        ]
      }
    end

    test "using keyword syntax", %{expected: expected} do
      query =
        from(t in "tracks",
          join: a in "albums",
          on: t.album_id == a.id,
          select: %{id: t.id, title: t.title, album: a.title},
          order_by: [t.title],
          where: t.duration >= 900
        )

      assert Repo.all(query) == expected
    end

    test "using macro syntax", %{expected: expected} do
      query =
        "tracks"
        |> join(:inner, [t], a in "albums", on: t.album_id == a.id)
        |> where([t], t.duration >= 900)
        |> order_by([t], [t.title])
        |> select([t, a], %{id: t.id, title: t.title, album: a.title})

      assert Repo.all(query) == expected
    end
  end

  describe "a very simple query" do
    setup do
      Repo.insert_all("artists", [[name: "joe"], [name: "shmoe"]])

      query = from("artists", select: [:name])
      %{query: query}
    end

    test "query data structure", %{query: query} do
      assert %Query{} = query

      assert Repo.to_sql(:all, query) ==
               {"SELECT a0.\"name\" FROM \"artists\" AS a0", []}
    end

    test "running the query", %{query: query} do
      assert Repo.all(query) == [%{name: "joe"}, %{name: "shmoe"}]
    end

    test "table name is the only required parameter to Ecto.Query.from" do
      query =
        Ecto.Query.from("artists")
        |> Ecto.Query.select([:name])

      assert Repo.to_sql(:all, query) == {"SELECT a0.\"name\" FROM \"artists\" AS a0", []}
      assert Repo.all(query) == [%{name: "joe"}, %{name: "shmoe"}]
    end
  end
end
