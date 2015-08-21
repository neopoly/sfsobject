defmodule SFSObjectTest do
  use ExUnit.Case

  test "new" do
    object = SFSObject.new
    assert object.data == %{}
  end

  test "null" do
    object = SFSObject.new
    assert SFSObject.is_null?(object, "key") == false

    object = SFSObject.put_null(object, "key")
    assert SFSObject.is_null?(object, "key") == true
  end

  test "bool" do
    object = SFSObject.new
    assert SFSObject.get_bool(object, "key") == nil

    object = SFSObject.put_bool(object, "key", true)
    assert SFSObject.get_bool(object, "key") == true

    object = SFSObject.put_bool(object, "key", false)
    assert SFSObject.get_bool(object, "key") == false
  end

  test "byte" do
    object = SFSObject.new
    assert SFSObject.get_byte(object, "key") == nil

    object = SFSObject.put_byte(object, "key", 1)
    assert SFSObject.get_byte(object, "key") == 1

    object = SFSObject.put_byte(object, "key", -2)
    assert SFSObject.get_byte(object, "key") == -2
  end

  test "short" do
    object = SFSObject.new
    assert SFSObject.get_short(object, "key") == nil

    object = SFSObject.put_short(object, "key", 1)
    assert SFSObject.get_short(object, "key") == 1

    object = SFSObject.put_short(object, "key", -2)
    assert SFSObject.get_short(object, "key") == -2
  end

  test "int" do
    object = SFSObject.new
    assert SFSObject.get_int(object, "key") == nil

    object = SFSObject.put_int(object, "key", 1)
    assert SFSObject.get_int(object, "key") == 1

    object = SFSObject.put_int(object, "key", -2)
    assert SFSObject.get_int(object, "key") == -2
  end

  test "long" do
    object = SFSObject.new
    assert SFSObject.get_long(object, "key") == nil

    object = SFSObject.put_long(object, "key", 1)
    assert SFSObject.get_long(object, "key") == 1

    object = SFSObject.put_long(object, "key", -2)
    assert SFSObject.get_long(object, "key") == -2
  end

  test "float" do
    object = SFSObject.new
    assert SFSObject.get_float(object, "key") == nil

    object = SFSObject.put_float(object, "key", 1.0)
    assert SFSObject.get_float(object, "key") == 1.0

    object = SFSObject.put_float(object, "key", -2.0)
    assert SFSObject.get_float(object, "key") == -2.0
  end

  test "double" do
    object = SFSObject.new
    assert SFSObject.get_double(object, "key") == nil

    object = SFSObject.put_double(object, "key", 1.0)
    assert SFSObject.get_double(object, "key") == 1.0

    object = SFSObject.put_double(object, "key", -2.0)
    assert SFSObject.get_double(object, "key") == -2.0
  end

  test "string" do
    object = SFSObject.new
    assert SFSObject.get_string(object, "key") == nil

    object = SFSObject.put_string(object, "key", "José")
    assert SFSObject.get_string(object, "key") == "José"

    object = SFSObject.put_string(object, "key", "other")
    assert SFSObject.get_string(object, "key") == "other"
  end
end
