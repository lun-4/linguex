defmodule LinguexTest do
  use ExUnit.Case
  doctest Linguex

  test "greets the world" do
    assert Linguex.hello() == :world
  end
end
