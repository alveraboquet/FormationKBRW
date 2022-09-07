defmodule Server.DatabaseTest do
  use ExUnit.Case

  setup do
    {_, database} = Server.Database.start_link(:ok)
    %{pid: database}
  end

  # Send a call with good and wrong request
  test "server interaction", %{pid: _} do
    assert Server.Database.call({:create, :table}) == :ok
    assert Server.Database.call({:notarequest, :table}) == :error
  end

end
