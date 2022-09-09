defmodule Server.JsonLoaderTest do
  use ExUnit.Case

  setup do
    {:ok, database} = Server.Database.start_link(:ok)
    %{pid: database}
  end

  test "JSON loading and writing in database", %{pid: _} do
    # Everything is good
    assert Server.JsonLoader.load_to_database(TutoKbrwStack, "./orders_dump/orders_chunk0.json") == :ok
    assert Server.JsonLoader.load_to_database(TutoKbrwStack, "./orders_dump/orders_chunk1.json") == :ok
  end

end
