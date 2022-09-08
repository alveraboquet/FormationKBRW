defmodule Server.DatabaseTest do
  use ExUnit.Case

  setup do
    {_, database} = Server.Database.start_link(:ok)
    %{pid: database}
  end

  # Send a call with good and wrong request
  test "calling the database", %{pid: _} do
    # Create a table and create another one with the same name
    assert Server.Database.create(:table) == :ok
    assert Server.Database.create(:table) == :error

    # Write a new set of key/value, checking if we can modify the set and what is happening if we put a non existing table
    assert Server.Database.write(:table, :working, "thisisworking") == :ok
    assert Server.Database.write(:table, :working, "thiswork") == :ok
    assert Server.Database.write(:notable, :notworking, "thisdoesntwork") == :error

    # Read an existing set of key/value, a non existing set of key/value and a non existing table
    assert Server.Database.read(:table, :working) == [{:working, "thiswork"}]
    assert Server.Database.read(:table, :notworking) == []
    assert Server.Database.read(:notable, :notworking) == :error

    # Put data in the db and try to search for them
    Server.Database.create(:search)
    Server.JsonLoader.load_to_database(:search, "./step6_order.json")
    {:ok, orders} = Server.Database.search(:search, [{"key", "42"}])
    assert orders == [%{:id => "test", "key" => "42"}]
    {:ok, orders} = Server.Database.search(:search, [{"key", "42"}, {"key", 42}])
    assert orders == [%{:id => "test", "key" => "42"}, %{:id => "toto", "key" => 42}]
    {:ok, orders} = Server.Database.search(:search, [{"id", "52"}, {"id", "ThisIsATest"}])
    assert orders == []
    # Delete a set of key/value, delete it again, delete a non existing set and on a non existing table
    assert Server.Database.delete(:table, :working) == :ok
    assert Server.Database.delete(:table, :working) == :ok
    assert Server.Database.delete(:table, :notworking) == :ok
    assert Server.Database.delete(:notable, :notworking) == :error

    # Delete a table, delete it again and delete a non existing one
    assert Server.Database.delete(:table) == :ok
    assert Server.Database.delete(:table) == :error
    assert Server.Database.delete(:notable) == :error
  end

end
