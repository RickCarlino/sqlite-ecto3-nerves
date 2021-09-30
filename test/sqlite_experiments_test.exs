defmodule SqliteExperimentsTest do
  use ExUnit.Case
  doctest SqliteExperiments

  test "greets the world" do
    assert SqliteExperiments.hello() == :world
  end
end
