defmodule TutoKbrwStackTest do
  use ExUnit.Case
  doctest TutoKbrwStack

  setup do
    {:ok, database} = Server.Database.start_link(:ok)
    %{pid: database}
  end

  test "calling the database", %{pid: _} do
    # Create a table and create another one with the same name
    assert TutoKbrwStack.create(:table) == :ok
    assert TutoKbrwStack.create(:table) == :error

    # Write a new set of key/value, checking if we can modify the set and what is happening if we put a non existing table
    assert TutoKbrwStack.write(:table, :working, "thisisworking") == :ok
    assert TutoKbrwStack.write(:table, :working, "thiswork") == :ok
    assert TutoKbrwStack.write(:notable, :notworking, "thisdoesntwork") == :error

    # Read an existing set of key/value, a non existing set of key/value and a non existing table
    assert TutoKbrwStack.read(:table, :working) == [{:working, "thiswork"}]
    assert TutoKbrwStack.read(:table, :notworking) == []
    assert TutoKbrwStack.read(:notable, :notworking) == :error

    # delete a set of key/value, delete it again, delete a non existing set and on a non existing table
    assert TutoKbrwStack.delete(:table, :working) == :ok
    assert TutoKbrwStack.delete(:table, :working) == :ok
    assert TutoKbrwStack.delete(:table, :notworking) == :ok
    assert TutoKbrwStack.delete(:notable, :notworking) == :error

    # delete a table, delete it again and delete a non existing one
    assert TutoKbrwStack.delete(:table) == :ok
    assert TutoKbrwStack.delete(:table) == :error
    assert TutoKbrwStack.delete(:notable) == :error

  end
end
