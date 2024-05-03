defmodule Examples.Query12Test do
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

    {4, [%{id: album_a_id}, %{id: album_b_id}, %{id: album_c_id}, %{id: album_d_id}]} =
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
          ] ++ timestamps,
          [
            title: "album d",
            artist_id: artist_one_id
          ] ++ timestamps
        ],
        returning: [:id]
      )

    {5, _} =
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
            duration: 903
          ] ++ timestamps,
          [
            album_id: album_d_id,
            title: "d track 1",
            index: 2,
            duration: 904
          ] ++ timestamps
        ],
        returning: [:id]
      )

    :ok
  end

  def by_artist(album_query, name) do
    from album in album_query,
      join: artist in "artists",
      on: artist.id == album.artist_id,
      where: artist.name == ^name
  end

  def with_tracks_longer_than(album_query, duration) do
    from album in album_query,
      join: track in "tracks",
      on: track.album_id == album.id,
      where: track.duration > ^duration
  end

  def albums_by_artist(name), do: by_artist("albums", name)

  test "composing queries with functions" do
    query =
      albums_by_artist("one")
      |> order_by([a], desc: a.title)
      |> select([a], a.title)

    assert Repo.all(query) == [
             "album d",
             "album c",
             "album a"
           ]

    query =
      "albums"
      |> by_artist("one")
      |> with_tracks_longer_than(901)
      |> order_by([a], desc: a.title)
      |> select([a], a.title)

    assert Repo.all(query) == [
             "album d",
             "album c"
           ]
  end
end
