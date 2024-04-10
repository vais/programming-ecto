defmodule Examples.GettingStarted01Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  alias MusicDB.Artist

  describe "the repository pattern" do
    test "crud" do
      {:ok, inserted} = Repo.insert(%Artist{name: "formerly known as prince"})

      selected = Repo.get_by(Artist, name: "formerly known as prince")
      assert inserted == selected

      {:ok, updated} =
        selected
        |> Ecto.Changeset.change(name: "bye")
        |> Repo.update()

      selected = Repo.get_by(Artist, name: "bye")
      assert updated == selected

      {:ok, deleted} = Repo.delete(selected)

      selected = Repo.get_by(Artist, name: "bye")
      assert selected == nil
    end
  end
end
