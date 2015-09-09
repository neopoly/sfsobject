defmodule SFSObject.DataWrapperTest do
  use ExUnit.Case

  defmodule CoderTest do
    use ExUnit.Case

    test "null" do
      assert_roundtrip data_wrapper(:null)
    end

    test "bool" do
      assert_roundtrip data_wrapper(:bool, true)
      assert_roundtrip data_wrapper(:bool, false)
    end

    defp assert_roundtrip(value) do
      encoded = value |> SFSObject.DataWrapper.Encoder.encode
      decoded = encoded |> to_string |> SFSObject.DataWrapper.Decoder.decode

      assert {^value, <<>>} = decoded
    end

    defp data_wrapper(:null = type) do
      data_wrapper(type, :null)
    end

    defp data_wrapper(type, value) do
      SFSObject.DataWrapper.new(type, value)
    end
  end
end