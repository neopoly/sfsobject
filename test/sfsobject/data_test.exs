defmodule SFSObject.DataTest do
  use ExUnit.Case
  alias SFSObject.Data

  test "Null" do
    assert Data.Null.new == %Data.Null{}
  end

  test "Byte" do
    assert Data.Byte.new(1) == %Data.Byte{v: 1}
  end

  # TODO more
end
