defmodule SFSObject.DataWrapperTest do
  use ExUnit.Case

  defmodule CoderTest do
    use ExUnit.Case
    import SFSObject

    test "null" do
      assert_roundtrip null
    end

    test "bool" do
      assert_roundtrip bool(true)
      assert_roundtrip bool(false)
    end

    test "byte" do
      assert_roundtrip byte(0)
      assert_roundtrip byte(127)
      assert_roundtrip byte(-128)

      assert_roundtrip byte(128), byte(-128)
      assert_roundtrip byte(-129), byte(127)
    end

    test "short" do
      assert_roundtrip short(0)
      assert_roundtrip short(32767)
      assert_roundtrip short(-32768)

      assert_roundtrip short(32768), short(-32768)
      assert_roundtrip short(-32769), short(32767)
    end

    test "int" do
      assert_roundtrip int(0)
      assert_roundtrip int(2147483647)
      assert_roundtrip int(-2147483648)

      assert_roundtrip int(2147483648), int(-2147483648)
      assert_roundtrip int(-2147483649), int(2147483647)
    end

    test "long" do
      assert_roundtrip long(0)
      assert_roundtrip long(9223372036854775807)
      assert_roundtrip long(-9223372036854775808)

      assert_roundtrip long(9223372036854775808), long(-9223372036854775808)
      assert_roundtrip long(-9223372036854775809), long(9223372036854775807)
    end

    test "float" do
      assert_roundtrip float(0.0)
      assert_roundtrip float(-1.0)
      # TODO assert_roundtrip float(-1.01)
    end

    test "double" do
      assert_roundtrip double(0.0)
      assert_roundtrip double(-1.0)
      assert_roundtrip double(-1.01)
    end

    test "string" do
      assert_roundtrip string("foo")
      assert_roundtrip string("José")

      assert_decoded <<8, 0, 5, 74, 111, 115, -61, -87>>, string("José")
    end

    test "bool_array" do
      assert_roundtrip bool_array([true, false])

      assert_decoded <<9, 0, 2, 1, 0>>, bool_array([true, false])
    end

    test "sfsobject" do
      assert_roundtrip object(SFSObject.new)

      assert_roundtrip object(SFSObject.new |> put_null("a"))
      assert_roundtrip object(SFSObject.new |> put_null("b"))
      assert_roundtrip object(SFSObject.new
      |> put_bool("truthy", true) |> put_bool("falsey", false))
    end

    test "sfsobject nested" do
      assert_roundtrip data :object, SFSObject.new
      |> put_object("nested", SFSObject.new |> put_null("null"))
    end

    defp assert_roundtrip(value) do
      assert_roundtrip(value, value)
    end

    defp assert_roundtrip(value, expected) do
      encoded = value |> SFSObject.DataWrapper.Encoder.encode
      assert_decoded encoded, expected
    end

    def assert_decoded(input, expected) do
      { actual, rest } = input |> IO.iodata_to_binary |> SFSObject.DataWrapper.Decoder.decode

      assert expected == actual
      assert <<>> == rest
    end

    defp null, do: data(:null, :null)
    defp bool(value), do: data(:bool, value)
    defp byte(value), do: data(:byte, value)
    defp short(value), do: data(:short, value)
    defp int(value), do: data(:int, value)
    defp long(value), do: data(:long, value)
    defp float(value), do: data(:float, value)
    defp double(value), do: data(:double, value)
    defp string(value), do: data(:string, value)
    defp bool_array(list), do: data(:bool_array, list)
    defp object(value), do: data(:object, value)

    defp data(type, value) do
      SFSObject.DataWrapper.new(type, value)
    end
  end
end
