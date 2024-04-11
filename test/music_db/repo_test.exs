defmodule MusicDB.RepoTest do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo

  describe "count/1" do
    test "returns the number of rows in a table" do
      assert Repo.count("artists") == 0
      {2, nil} = Repo.insert_all("artists", [[name: "one"], [name: "two"]])
      assert Repo.count("artists") == 2
    end
  end
end
