defmodule Examples.Query14Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  import Ecto.Query

  setup do
    vals = [index: 0, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()]
    Repo.insert_all("tracks", [[title: "hello"] ++ vals, [title: "bye"] ++ vals])
    :ok
  end

  test "updating and deleting queryables" do
    indexes = "tracks" |> select([t], t.index) |> Repo.all()
    assert indexes == [0, 0]

    from(t in "tracks", where: t.title == "bye")
    |> Repo.update_all(set: [index: 1])

    indexes = "tracks" |> select([t], t.index) |> Repo.all()
    assert Enum.sort(indexes) == [0, 1]
  end

  test "deleting a quryable" do
    titles = "tracks" |> select([t], t.title) |> Repo.all()
    assert Enum.sort(titles) == ["bye", "hello"]

    from(t in "tracks", where: t.title == "bye")
    |> Repo.delete_all()

    titles = "tracks" |> select([t], t.title) |> Repo.all()
    assert Enum.sort(titles) == ["hello"]
  end
end
