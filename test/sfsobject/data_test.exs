defmodule SFSObject.DataTest do
  use ExUnit.Case
  alias SFSObject.Data

  test "Null" do
    assert %Data.Null{}
  end

  test "Bool" do
    assert %Data.Bool{v: true}
  end

  test "Byte" do
    assert %Data.Byte{v: 1}
  end

  # TODO more
end
