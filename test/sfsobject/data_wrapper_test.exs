defmodule SFSObject.DataWrapperTest do
  use ExUnit.Case

  defmodule CoderTest do
    use ExUnit.Case
    import SFSObject

    test "null" do
      assert_roundtrip data_wrapper(:null)
    end

    test "bool" do
      assert_roundtrip data_wrapper(:bool, true)
      assert_roundtrip data_wrapper(:bool, false)
    end

    test "sfsobject" do
      assert_roundtrip data_wrapper(:object, SFSObject.new)

      assert_roundtrip data_wrapper(:object, SFSObject.new |> put_null("a"))
      assert_roundtrip data_wrapper(:object, SFSObject.new |> put_null("b"))
      assert_roundtrip data_wrapper(:object, SFSObject.new
      |> put_bool("truthy", true) |> put_bool("falsey", false))
    end

    test "sfsobject nested" do
      assert_roundtrip data_wrapper :object, SFSObject.new
      |> put_object("nested", SFSObject.new |> put_null("null"))
    end

    defp assert_roundtrip(value) do
      assert_roundtrip value, value
    end

    defp assert_roundtrip(value, expected) do
      encoded = value |> SFSObject.DataWrapper.Encoder.encode
      { actual, rest } = encoded |> to_string |> SFSObject.DataWrapper.Decoder.decode

      assert expected == actual
      assert <<>> == rest
    end

    defp data_wrapper(:null = type) do
      data_wrapper(type, :null)
    end

    defp data_wrapper(type, value) do
      SFSObject.DataWrapper.new(type, value)
    end
  end
end
