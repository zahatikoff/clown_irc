defmodule ClownIRCTest do
  use ExUnit.Case
  doctest ClownIRC

  test "greets the world" do
    assert ClownIRC.hello() == :world
  end
end
