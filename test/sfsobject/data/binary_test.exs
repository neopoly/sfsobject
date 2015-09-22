defmodule SFSObject.Data.BinaryTest do
  use ExUnit.Case

  defmodule CoderTest do
    use ExUnit.Case
    import SFSObject
    alias SFSObject.Data

    test "Data.Null.new" do
      assert_roundtrip %Data.Null{}
      assert_decoded <<0>>, %Data.Null{}
    end

    test "Data.Bool.new" do
      assert_roundtrip %Data.Bool{v: true}
      assert_roundtrip %Data.Bool{v: false}
      assert_decoded <<1, 1>>, %Data.Bool{v: true}
    end

    test "Data.Byte.new" do
      assert_roundtrip %Data.Byte{v: 0}
      assert_roundtrip %Data.Byte{v: 127}
      assert_roundtrip %Data.Byte{v: -128}
      assert_roundtrip %Data.Byte{v: 128}, %Data.Byte{v: -128}
      assert_roundtrip %Data.Byte{v: -129}, %Data.Byte{v: 127}
      assert_decoded <<2, 1>>, %Data.Byte{v: 1}
    end

    test "Data.Short.new" do
      assert_roundtrip %Data.Short{v: 0}
      assert_roundtrip %Data.Short{v: 32767}
      assert_roundtrip %Data.Short{v: -32768}
      assert_roundtrip %Data.Short{v: 32768}, %Data.Short{v: -32768}
      assert_roundtrip %Data.Short{v: -32769}, %Data.Short{v: 32767}
      assert_decoded <<3, 0, 1>>, %Data.Short{v: 1}
    end

    test "Data.Int.new" do
      assert_roundtrip %Data.Int{v: 0}
      assert_roundtrip %Data.Int{v: 2147483647}
      assert_roundtrip %Data.Int{v: -2147483648}
      assert_roundtrip %Data.Int{v: 2147483648}, %Data.Int{v: -2147483648}
      assert_roundtrip %Data.Int{v: -2147483649}, %Data.Int{v: 2147483647}
      assert_decoded <<4, 0, 0, 0, 1>>, %Data.Int{v: 1}
    end

    test "Data.Long.new" do
      assert_roundtrip %Data.Long{v: 0}
      assert_roundtrip %Data.Long{v: 9223372036854775807}
      assert_roundtrip %Data.Long{v: -9223372036854775808}
      assert_roundtrip %Data.Long{v: 9223372036854775808}, %Data.Long{v: -9223372036854775808}
      assert_roundtrip %Data.Long{v: -9223372036854775809}, %Data.Long{v: 9223372036854775807}
      assert_decoded <<5, 0, 0, 0, 0, 0, 0, 0, 1>>, %Data.Long{v: 1}
    end

    test "Data.Float.new" do
      assert_roundtrip %Data.Float{v: 0.0}
      assert_roundtrip %Data.Float{v: -1.0}
      # TODO assert_roundtrip %Data.Float{v: -1.01}
      assert_decoded <<6, 63, -128, 0, 0>>, %Data.Float{v: 1.0}
    end

    test "Data.Double.new" do
      assert_roundtrip %Data.Double{v: 0.0}
      assert_roundtrip %Data.Double{v: -1.0}
      assert_roundtrip %Data.Double{v: -1.01}
      assert_decoded <<7, 63, -16, 0, 0, 0, 0, 0, 0>>, %Data.Double{v: 1.0}
    end

    test "Data.String.new" do
      assert_roundtrip %Data.String{v: "foo"}
      assert_roundtrip %Data.String{v: "José"}
      assert_decoded <<8, 0, 5, 74, 111, 115, -61, -87>>, %Data.String{v: "José"}
    end

    test "Data.Bool.new_array" do
      assert_roundtrip %Data.BoolArray{v: [true, false]}
      assert_decoded <<9, 0, 2, 1, 0>>, %Data.BoolArray{v: [true, false]}
    end

    test "Data.Byte.new_array" do
      assert_roundtrip %Data.ByteArray{v: [127, -128]}
      assert_decoded <<10, 0, 0, 0, 3, 1, 2, 3>>, %Data.ByteArray{v: [1, 2, 3]}
    end

    test "Data.Short.new_array" do
      assert_roundtrip %Data.ShortArray{v: [32767, -32768]}
      assert_decoded <<11, 0, 3, 0, 1, 0, 2, 0, 3>>, %Data.ShortArray{v: [1, 2, 3]}
    end

    test "Data.Int.new_array" do
      assert_roundtrip %Data.IntArray{v: [2147483647, -2147483648]}
      assert_decoded <<12, 0, 1, 0, 0, 0, 1>>, %Data.IntArray{v: [1]}
    end

    test "Data.Long.new_array" do
      assert_roundtrip %Data.LongArray{v: [9223372036854775807, -9223372036854775808]}
      assert_decoded <<13, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1>>, %Data.LongArray{v: [1]}
    end

    test "Data.Float.new_array" do
      assert_roundtrip %Data.FloatArray{v: [1.0, -1.0]}
      assert_decoded <<14, 0, 1, 63, -128, 0, 0>>, %Data.FloatArray{v: [1.0]}
    end

    test "Data.Double.new_array" do
      assert_roundtrip %Data.DoubleArray{v: [1.0, -1.0]}
      assert_decoded <<15, 0, 1, 63, -16, 0, 0, 0, 0, 0, 0>>, %Data.DoubleArray{v: [1.0]}
    end

    test "Data.String.new_array" do
      assert_roundtrip %Data.StringArray{v: ["José", "Valim"]}
      assert_decoded <<16, 0, 2, 0, 5, 74, 111, 115, -61, -87, 0, 5, 86, 97, 108, 105, 109>>,
        %Data.StringArray{v: ["José", "Valim"]}
    end

    test "sfsarray" do
      assert_roundtrip %Data.Array{v: [%Data.Bool{v: true}, %Data.Bool{v: false}, %Data.String{v: "José"}]}
      assert_decoded <<17, 0, 3, 1, 1, 1, 0, 8, 0, 5, 74, 111, 115, -61, -87>>,
        %Data.Array{v: [%Data.Bool{v: true}, %Data.Bool{v: false}, %Data.String{v: "José"}]}
    end

    test "sfsobject" do
      assert_roundtrip %Data.Object{v: SFSObject.new}
      assert_roundtrip %Data.Object{v: SFSObject.new |> put_null("a")}
      assert_roundtrip %Data.Object{v: SFSObject.new |> put_null("b")}
      assert_roundtrip %Data.Object{v: SFSObject.new
        |> put_bool("truthy", true) |> put_bool("falsey", false)}
      assert_decoded <<18, 0, 1, 0, 1, 97, 0>>,
        %Data.Object{v: SFSObject.new |> put_null("a")}
    end

    test "sfsobject nested" do
      assert_roundtrip %Data.Object{v: SFSObject.new
        |> put_object("nested", SFSObject.new |> put_null("null"))}
      assert_decoded <<18, 0, 1, 0, 1, 97, 18, 0, 0>>,
        %Data.Object{v: SFSObject.new |> put_object("a", SFSObject.new)}
    end

    defp assert_roundtrip(value) do
      assert_roundtrip(value, value)
    end

    defp assert_roundtrip(value, expected) do
      encoded = value |> SFSObject.Data.Binary.Encoder.encode
      assert_decoded encoded, expected
    end

    def assert_decoded(input, expected) do
      { actual, rest } = input |> SFSObject.Data.Binary.Decoder.decode

      assert expected == actual
      assert <<>> == rest
    end
  end
end
