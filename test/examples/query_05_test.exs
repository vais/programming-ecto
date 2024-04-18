defmodule Examples.Query05Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    {1, [%{id: artist_id}]} =
      Repo.insert_all(
        "artists",
        [[name: "Bill Evans"]],
        returning: [:id]
      )

    %{artist_id: artist_id}
  end

  test """
       QUERY BINDINGS effectively give you variables for
       referring to specific tables throughout your query
       """,
       %{artist_id: artist_id} do
    query =
      from(artist in "artists",
        where: artist.name == "Bill Evans",
        left_join: album in "albums",
        on: album.artist_id == artist.id,
        select: %{
          id: artist.id,
          artist_name: artist.name,
          album_title: album.title
        }
      )

    assert Repo.all(query) == [
             %{
               id: artist_id,
               artist_name: "Bill Evans",
               album_title: nil
             }
           ]
  end
end
