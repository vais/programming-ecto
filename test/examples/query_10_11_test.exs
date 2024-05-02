defmodule Examples.Query10Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    {2, [%{id: artist_one_id}, %{id: artist_two_id}]} =
      Repo.insert_all(
        "artists",
        [
          [name: "one"],
          [name: "two"]
        ],
        returning: [:id]
      )

    timestamps = [
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    ]

    {3, [%{id: album_a_id}, %{id: album_b_id}, %{id: album_c_id}]} =
      Repo.insert_all(
        "albums",
        [
          [
            title: "album a",
            artist_id: artist_one_id
          ] ++ timestamps,
          [
            title: "album b",
            artist_id: artist_two_id
          ] ++ timestamps,
          [
            title: "album c",
            artist_id: artist_one_id
          ] ++ timestamps
        ],
        returning: [:id]
      )

    {4, _} =
      Repo.insert_all(
        "tracks",
        [
          [
            album_id: album_a_id,
            title: "a track 1",
            index: 0,
            duration: 900
          ] ++ timestamps,
          [
            album_id: album_a_id,
            title: "a track 2",
            index: 1,
            duration: 901
          ] ++ timestamps,
          [
            album_id: album_b_id,
            title: "b track 1",
            index: 2,
            duration: 902
          ] ++ timestamps,
          [
            album_id: album_c_id,
            title: "c track 1",
            index: 2,
            duration: 902
          ] ++ timestamps
        ],
        returning: [:id]
      )

    :ok
  end

  test "composing queries" do
    albums_by_an_artist =
      from album in "albums",
        as: :album,
        join: artist in "artists",
        as: :artist,
        on: album.artist_id == artist.id,
        where: artist.name == "one"

    assert Repo.all(from a in albums_by_an_artist, select: a.title) ==
             ["album a", "album c"]

    assert Repo.all(from [artist: a] in albums_by_an_artist, select: a.name) ==
             ["one", "one"]

    tracks_on_albums_by_an_artist =
      from [album: album] in albums_by_an_artist,
        join: track in "tracks",
        on: track.album_id == album.id,
        select: track.title

    assert Repo.all(tracks_on_albums_by_an_artist) ==
             ["a track 1", "a track 2", "c track 1"]
  end
end
