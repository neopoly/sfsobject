defmodule SFSObject.BinaryTest do
  use ExUnit.Case

  defmodule CoderTest do
    use ExUnit.Case
    import SFSObject

    test "null" do
      assert_roundtrip null
      assert_decoded <<0>>, null
    end

    test "bool" do
      assert_roundtrip bool(true)
      assert_roundtrip bool(false)
      assert_decoded <<1, 1>>, bool(true)
    end

    test "byte" do
      assert_roundtrip byte(0)
      assert_roundtrip byte(127)
      assert_roundtrip byte(-128)
      assert_roundtrip byte(128), byte(-128)
      assert_roundtrip byte(-129), byte(127)
      assert_decoded <<2, 1>>, byte(1)
    end

    test "short" do
      assert_roundtrip short(0)
      assert_roundtrip short(32767)
      assert_roundtrip short(-32768)
      assert_roundtrip short(32768), short(-32768)
      assert_roundtrip short(-32769), short(32767)
      assert_decoded <<3, 0, 1>>, short(1)
    end

    test "int" do
      assert_roundtrip int(0)
      assert_roundtrip int(2147483647)
      assert_roundtrip int(-2147483648)
      assert_roundtrip int(2147483648), int(-2147483648)
      assert_roundtrip int(-2147483649), int(2147483647)
      assert_decoded <<4, 0, 0, 0, 1>>, int(1)
    end

    test "long" do
      assert_roundtrip long(0)
      assert_roundtrip long(9223372036854775807)
      assert_roundtrip long(-9223372036854775808)
      assert_roundtrip long(9223372036854775808), long(-9223372036854775808)
      assert_roundtrip long(-9223372036854775809), long(9223372036854775807)
      assert_decoded <<5, 0, 0, 0, 0, 0, 0, 0, 1>>, long(1)
    end

    test "float" do
      assert_roundtrip float(0.0)
      assert_roundtrip float(-1.0)
      # TODO assert_roundtrip float(-1.01)
      assert_decoded <<6, 63, -128, 0, 0>>, float(1.0)
    end

    test "double" do
      assert_roundtrip double(0.0)
      assert_roundtrip double(-1.0)
      assert_roundtrip double(-1.01)
      assert_decoded <<7, 63, -16, 0, 0, 0, 0, 0, 0>>, double(1.0)
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

    test "byte_array" do
      assert_roundtrip byte_array([127, -128])
      assert_decoded <<10, 0, 0, 0, 3, 1, 2, 3>>, byte_array([1, 2, 3])
    end

    test "short_array" do
      assert_roundtrip short_array([32767, -32768])
      assert_decoded <<11, 0, 3, 0, 1, 0, 2, 0, 3>>, short_array([1, 2, 3])
    end

    test "int_array" do
      assert_roundtrip int_array([2147483647, -2147483648])
      assert_decoded <<12, 0, 1, 0, 0, 0, 1>>, int_array([1])
    end

    test "long_array" do
      assert_roundtrip long_array([9223372036854775807, -9223372036854775808])
      assert_decoded <<13, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1>>, long_array([1])
    end

    test "float_array" do
      assert_roundtrip float_array([1.0, -1.0])
      assert_decoded <<14, 0, 1, 63, -128, 0, 0>>, float_array([1.0])
    end

    test "double_array" do
      assert_roundtrip double_array([1.0, -1.0])
      assert_decoded <<15, 0, 1, 63, -16, 0, 0, 0, 0, 0, 0>>, double_array([1.0])
    end

    test "string_array" do
      assert_roundtrip string_array(["José", "Valim"])
      assert_decoded <<16, 0, 2, 0, 5, 74, 111, 115, -61, -87, 0, 5, 86, 97, 108, 105, 109>>,
        string_array(["José", "Valim"])
    end

    test "sfsarray" do
      assert_roundtrip array([bool(true), bool(false), string("José")])
      assert_decoded <<17, 0, 3, 1, 1, 1, 0, 8, 0, 5, 74, 111, 115, -61, -87>>,
        array([bool(true), bool(false), string("José")])
    end

    test "sfsobject" do
      assert_roundtrip object(SFSObject.new)
      assert_roundtrip object(SFSObject.new |> put_null("a"))
      assert_roundtrip object(SFSObject.new |> put_null("b"))
      assert_roundtrip object(SFSObject.new
        |> put_bool("truthy", true) |> put_bool("falsey", false))
      assert_decoded <<18, 0, 1, 0, 1, 97, 0>>,
        object(SFSObject.new |> put_null("a"))
    end

    test "sfsobject nested" do
      assert_roundtrip object(SFSObject.new
        |> put_object("nested", SFSObject.new |> put_null("null")))
      assert_decoded <<18, 0, 1, 0, 1, 97, 18, 0, 0>>,
        object(SFSObject.new |> put_object("a", SFSObject.new))
    end

    defp null, do: {:null, :null}
    defp array(v), do: {:array, v}
    defp object(v), do: {:object, v}
    [:bool, :byte, :short, :int, :long, :float, :double, :string] |> Enum.each(fn type ->
      type_array = "#{type}_array" |> String.to_atom
      defp unquote(type)(v), do: {unquote(type), v}
      defp unquote(type_array)(v), do: {unquote(type_array), v}
    end)

    defp assert_roundtrip(value) do
      assert_roundtrip(value, value)
    end

    defp assert_roundtrip(value, expected) do
      encoded = value |> SFSObject.Binary.Encoder.encode
      assert_decoded encoded, expected
    end

    def assert_decoded(input, expected) do
      { actual, rest } = input |> SFSObject.Binary.Decoder.decode

      assert expected == actual
      assert <<>> == rest
    end
  end
end
