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

  test "bool_array" do
    object = SFSObject.new
    assert SFSObject.get_bool_array(object, "key") == nil

    object = SFSObject.put_bool_array(object, "key", [true,false])
    assert SFSObject.get_bool_array(object, "key") == [true,false]

    object = SFSObject.put_bool_array(object, "key", [false, false])
    assert SFSObject.get_bool_array(object, "key") == [false, false]
  end

  test "byte_array" do
    object = SFSObject.new
    assert SFSObject.get_byte_array(object, "key") == nil

    object = SFSObject.put_byte_array(object, "key", [1, 2])
    assert SFSObject.get_byte_array(object, "key") == [1, 2]

    object = SFSObject.put_byte_array(object, "key", [-2, 1])
    assert SFSObject.get_byte_array(object, "key") == [-2, 1]
  end

  test "short_array" do
    object = SFSObject.new
    assert SFSObject.get_short_array(object, "key") == nil

    object = SFSObject.put_short_array(object, "key", [1, 2])
    assert SFSObject.get_short_array(object, "key") == [1, 2]

    object = SFSObject.put_short_array(object, "key", [-2, 1])
    assert SFSObject.get_short_array(object, "key") == [-2, 1]
  end

  test "int_array" do
    object = SFSObject.new
    assert SFSObject.get_int_array(object, "key") == nil

    object = SFSObject.put_int_array(object, "key", [1, 2])
    assert SFSObject.get_int_array(object, "key") == [1, 2]

    object = SFSObject.put_int_array(object, "key", [-2, 1])
    assert SFSObject.get_int_array(object, "key") == [-2, 1]
  end

  test "long_array" do
    object = SFSObject.new
    assert SFSObject.get_long_array(object, "key") == nil

    object = SFSObject.put_long_array(object, "key", [1, 2])
    assert SFSObject.get_long_array(object, "key") == [1, 2]

    object = SFSObject.put_long_array(object, "key", [-2, 1])
    assert SFSObject.get_long_array(object, "key") == [-2, 1]
  end

  test "float_array" do
    object = SFSObject.new
    assert SFSObject.get_float_array(object, "key") == nil

    object = SFSObject.put_float_array(object, "key", [1.5, 2.0])
    assert SFSObject.get_float_array(object, "key") == [1.5, 2.0]

    object = SFSObject.put_float_array(object, "key", [-2.0, 1.5])
    assert SFSObject.get_float_array(object, "key") == [-2.0, 1.5]
  end

  test "double_array" do
    object = SFSObject.new
    assert SFSObject.get_double_array(object, "key") == nil

    object = SFSObject.put_double_array(object, "key", [1.5, 2.0])
    assert SFSObject.get_double_array(object, "key") == [1.5, 2.0]

    object = SFSObject.put_double_array(object, "key", [-2.0, 1.5])
    assert SFSObject.get_double_array(object, "key") == [-2.0, 1.5]
  end

  test "string_array" do
    object = SFSObject.new
    assert SFSObject.get_string_array(object, "key") == nil

    object = SFSObject.put_string_array(object, "key", ["José", "Valim"])
    assert SFSObject.get_string_array(object, "key") == ["José", "Valim"]

    object = SFSObject.put_string_array(object, "key", ["other", "string"])
    assert SFSObject.get_string_array(object, "key") == ["other", "string"]
  end

  test "array" do
    object = SFSObject.new
    assert SFSObject.get_array(object, "key") == nil

    string = %SFSObject.Data.String{v: "hello"}
    int = %SFSObject.Data.Int{v: 1}

    object = SFSObject.put_array(object, "key", [string, int])

    got = SFSObject.get_array(object, "key")
    assert got == [string, int]
  end

  test "object" do
    object = SFSObject.new
    other = SFSObject.new

    assert SFSObject.get_object(object, "other") == nil

    object = SFSObject.put_object(object, "other", other)
    assert SFSObject.get_object(object, "other") == other
  end

  test "class" do
    object = SFSObject.new

    assert_raise RuntimeError, fn ->
      SFSObject.get_class(object, "klass")
    end

    assert_raise RuntimeError, fn ->
      SFSObject.put_class(object, "klass", :some_class)
    end
  end

  test "encode/decode" do
    assert_roundtrip SFSObject.new
  end

  defp assert_roundtrip(expected) do
    encoded = expected |> SFSObject.encode
    actual = encoded |> SFSObject.decode

    assert expected == actual
  end
end
