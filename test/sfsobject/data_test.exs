defmodule SFSObject.DataTest do
  use ExUnit.Case
  alias SFSObject.Data

  test "Null" do
    assert Data.Null.new == %Data.Null{}
  end

  test "Bool" do
    assert Data.Bool.new(true) == %Data.Bool{v: true}
  end

  test "Byte" do
    assert Data.Byte.new(1) == %Data.Byte{v: 1}
  end

  # TODO more
end

defmodule SFSObject.Data.Coder.BinaryTest do
  use ExUnit.Case
  alias SFSObject.Data

  test "null" do
    assert_roundtrip Data.Null.new
  end

  test "bool" do
    assert_roundtrip Data.Bool.new(true)
    assert_roundtrip Data.Bool.new(false)
  end

  test "byte" do
    assert_roundtrip Data.Byte.new(1)
    assert_roundtrip Data.Byte.new(129), Data.Byte.new(-127)
  end

  test "string" do
    assert_roundtrip Data.String.new("José")
  end

  def assert_roundtrip(data, expected) do
    binary = Data.Coder.Binary.encode(data)
    got = Data.Coder.Binary.decode(binary)
    assert got == expected
  end

  def assert_roundtrip(data) do
    assert_roundtrip data, data
  end
end
