defmodule Examples.Query09Test do
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

    {3, [%{id: album_a_id}, %{id: album_b_id}, _]} =
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

    {3, _} =
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
          ] ++ timestamps
        ],
        returning: [:id]
      )

    :ok
  end

  test "joins" do
    query =
      from track in "tracks",
        join: album in "albums",
        on: album.id == track.album_id,
        join: artist in "artists",
        on: artist.id == album.artist_id,
        where: track.duration > 900,
        select: %{album: album.title, track: track.title, artist: artist.name}

    assert Repo.all(query) ==
             [
               %{album: "album a", track: "a track 2", artist: "one"},
               %{album: "album b", track: "b track 1", artist: "two"}
             ]
  end
end
