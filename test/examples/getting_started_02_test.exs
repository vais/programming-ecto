defmodule Examples.GettingStarted02Test do
  use MusicDB.DataCase, async: true

  alias MusicDB.Repo
  alias MusicDB.Artist

  describe "insert_all" do
    test "inserting multiple records" do
      {3, nil} =
        Repo.insert_all("artists", [
          [name: "jane", inserted_at: DateTime.utc_now()],
          [name: "jake", inserted_at: DateTime.utc_now()],
          [name: "jill", inserted_at: DateTime.utc_now()]
        ])
    end

    test "using a string for table name" do
      {1, nil} = Repo.insert_all("artists", [[name: "joe"]])
    end

    test "using schema module for table name" do
      {1, nil} = Repo.insert_all(Artist, [[name: "joe"]])
    end

    test "using a list of maps" do
      {1, nil} = Repo.insert_all(Artist, [%{name: "joe"}])
    end

    test "returning id" do
      {2, [%{id: id, name: "joe"}, %{name: "shmoe"}]} =
        Repo.insert_all("artists", [%{name: "joe"}, %{name: "shmoe"}], returning: [:id, :name])

      assert is_integer(id)
    end
  end

  describe "query" do
    test "executing raw sql" do
      {2, nil} = Repo.insert_all("artists", [[name: "joe"], [name: "shmoe"]])
      {:ok, result} = Repo.query("select name from artists order by name desc")
      assert %Postgrex.Result{} = result
      assert result.columns == ["name"]
      assert result.rows == [["shmoe"], ["joe"]]

      {:ok, result} = Repo.query("delete from artists where name = 'shmoe'")
      assert result.num_rows == 1

      {:ok, result} = Repo.query("select name from artists")
      assert result.rows == [["joe"]]
    end
  end
end
