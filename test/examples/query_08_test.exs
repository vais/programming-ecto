defmodule Examples.Query08Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    Repo.insert_all("tracks", [
      [
        title: "hello",
        index: 0,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      ]
    ])

    Repo.insert_all("albums", [
      [
        title: "there",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      ]
    ])

    :ok
  end

  test "union queries" do
    query1 = from track in "tracks", select: %{title: track.title}
    assert Repo.all(query1) == [%{title: "hello"}]

    query2 = from album in "albums", select: %{title: album.title}
    assert Repo.all(query2) == [%{title: "there"}]

    query3 = from query1, union: ^query2, order_by: fragment("title")
    assert Repo.all(query3) == [%{title: "hello"}, %{title: "there"}]

    query4 =
      from u in subquery(from query1, union: ^query2),
        select: %{title: u.title},
        order_by: u.title

    assert Repo.all(query4) == [%{title: "hello"}, %{title: "there"}]
  end

  test "union queries (different select style)" do
    query1 = from track in "tracks", select: track.title
    assert Repo.all(query1) == ["hello"]

    query2 = from album in "albums", select: album.title
    assert Repo.all(query2) == ["there"]

    query3 = from query1, union: ^query2, order_by: fragment("title")
    assert Repo.all(query3) == ["hello", "there"]

    query4 =
      from u in subquery(from query1, union: ^query2),
        select: u.title,
        order_by: u.title

    assert Repo.all(query4) == ["hello", "there"]
  end
end
