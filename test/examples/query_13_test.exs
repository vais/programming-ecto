defmodule Examples.Query13Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    timestamps = [inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()]

    {2, [%{id: artist_one_id}, %{id: artist_two_id}]} =
      Repo.insert_all(
        "artists",
        [
          [name: "one"],
          [name: "two"]
        ],
        returning: [:id]
      )

    {4, _} =
      Repo.insert_all(
        "albums",
        [
          [title: "album a", artist_id: artist_one_id] ++ timestamps,
          [title: "album b", artist_id: artist_two_id] ++ timestamps,
          [title: "album c", artist_id: artist_one_id] ++ timestamps,
          [title: "album d", artist_id: artist_one_id] ++ timestamps
        ]
      )

    :ok
  end

  test "combining queries with or_where" do
    albums_by_artist_one =
      from album in "albums",
        join: artist in "artists",
        on: artist.id == album.artist_id,
        where: artist.name == "one"

    query =
      from [album, artist] in albums_by_artist_one,
        order_by: album.title,
        select: album.title

    assert Repo.all(query) == ["album a", "album c", "album d"]

    query =
      from [album, artist] in albums_by_artist_one,
        where: artist.name == "two",
        select: album.title

    assert Repo.all(query) == []

    query =
      from [album, artist] in albums_by_artist_one,
        or_where: artist.name == "two",
        order_by: album.title,
        select: album.title

    assert Repo.all(query) == ["album a", "album b", "album c", "album d"]
  end
end
