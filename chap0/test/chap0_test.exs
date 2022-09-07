defmodule Chap0Test do
  use ExUnit.Case
  doctest Chap0

  test "greets the world" do
    assert Chap0.hello() == :world
  end
end
