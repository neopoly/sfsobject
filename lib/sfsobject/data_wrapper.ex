defmodule SFSObject.DataWrapper do
  defstruct [:type, :value]

  def new(type, value) do
    %__MODULE__{type: type, value: value}
  end

  defmodule Encoder do
    alias SFSObject.DataWrapper

    def encode(data_wrapper, output \\ <<>>)
    def encode(%DataWrapper{type: :null}, output) do
      output <> <<0>>
    end

    def encode(%DataWrapper{type: :bool, value: value}, output) do
      output <> <<1, encode_bool(value)>>
    end

    def encode(%DataWrapper{type: :byte, value: value}, output) do
      output <> <<2, value::signed-size(8)>>
    end

    def encode(%DataWrapper{type: :short, value: value}, output) do
      output <> <<3, value::signed-size(16)>>
    end

    def encode(%DataWrapper{type: :int, value: value}, output) do
      output <> <<4, value::signed-size(32)>>
    end

    def encode(%DataWrapper{type: :long, value: value}, output) do
      output <> <<5, value::signed-size(64)>>
    end

    def encode(%DataWrapper{type: :float, value: value}, output) do
      output <> <<6, value::float-signed-size(32)>>
    end

    def encode(%DataWrapper{type: :double, value: value}, output) do
      output <> <<7, value::float-signed-size(64)>>
    end

    def encode(%DataWrapper{type: :string, value: value}, output) do
      size = byte_size(value)
      output <> <<8, size::size(16), value::binary>>
    end

    def encode(%DataWrapper{type: :bool_array, value: value}, output) do
      size = length(value)
      data = value |> Enum.map(&encode_bool/1) |> IO.iodata_to_binary
      output <> <<9, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :byte_array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<e::signed-size(8)>> end)
        |> IO.iodata_to_binary
      output <> <<10, size::size(32), data::binary>>
    end

    def encode(%DataWrapper{type: :short_array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<e::signed-size(16)>> end)
        |> IO.iodata_to_binary
      output <> <<11, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :int_array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<e::signed-size(32)>> end)
        |> IO.iodata_to_binary
      output <> <<12, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :long_array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<e::signed-size(64)>> end)
        |> IO.iodata_to_binary
      output <> <<13, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :float_array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<e::float-signed-size(32)>> end)
        |> IO.iodata_to_binary
      output <> <<14, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :double_array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<e::float-signed-size(64)>> end)
        |> IO.iodata_to_binary
      output <> <<15, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :string_array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<byte_size(e)::signed-size(16),e::binary>> end)
        |> IO.iodata_to_binary
      output <> <<16, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :array, value: value}, output) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> encode(e) end)
        |> IO.iodata_to_binary
      output <> <<17, size::size(16), data::binary>>
    end

    def encode(%DataWrapper{type: :object, value: %SFSObject{data: value}}, output) do
      size = Map.size(value)
      data = value
        |> Enum.flat_map(fn({key, value}) ->
            [ encode_key(key), encode(value) ]
          end)
        |> IO.iodata_to_binary
      output <> <<18, size::size(16), data::binary>>
    end

    defp encode_key(key) do
      <<String.length(key)::size(16), key::binary>>
    end

    defp encode_bool(true), do: 1
    defp encode_bool(false), do: 0
  end

  defmodule Decoder do
    alias SFSObject.DataWrapper

    def decode(<<0, input::bytes>>) do
      { DataWrapper.new(:null, :null), input }
    end

    def decode(<<1, 1, input::bytes>>) do
      { DataWrapper.new(:bool, true), input }
    end

    def decode(<<1, 0, input::bytes>>) do
      { DataWrapper.new(:bool, false), input }
    end

    def decode(<<2, value::signed-size(8), input::bytes>>) do
      { DataWrapper.new(:byte, value), input }
    end

    def decode(<<3, value::signed-size(16), input::bytes>>) do
      { DataWrapper.new(:short, value), input }
    end

    def decode(<<4, value::signed-size(32), input::bytes>>) do
      { DataWrapper.new(:int, value), input }
    end

    def decode(<<5, value::signed-size(64), input::bytes>>) do
      { DataWrapper.new(:long, value), input }
    end

    def decode(<<6, value::float-signed-size(32), input::bytes>>) do
      { DataWrapper.new(:float, value), input }
    end

    def decode(<<7, value::float-signed-size(64), input::bytes>>) do
      { DataWrapper.new(:double, value), input }
    end

    def decode(<<8, size::size(16), value::binary-size(size), input::bytes>>) do
      { DataWrapper.new(:string, value), input }
    end

    def decode(<<9, size::size(16), value::binary-size(size), input::bytes>>) do
      value = value |> to_char_list |> Enum.map(&decode_bool/1)
      { DataWrapper.new(:bool_array, value), input }
    end

    def decode(<<10, size::size(32), value::binary-size(size), input::bytes>>) do
      value = transform(size, 8, value)
      { DataWrapper.new(:byte_array, value), input }
    end

    def decode(<<11, size::size(16), value::binary-size(size)-unit(16), input::bytes>>) do
      value = transform(size, 16, value)
      { DataWrapper.new(:short_array, value), input }
    end

    def decode(<<12, size::size(16), value::binary-size(size)-unit(32), input::bytes>>) do
      value = transform(size, 32, value)
      { DataWrapper.new(:int_array, value), input }
    end

    def decode(<<13, size::size(16), value::binary-size(size)-unit(64), input::bytes>>) do
      value = transform(size, 64, value)
      { DataWrapper.new(:long_array, value), input }
    end

    def decode(<<14, size::size(16), value::binary-size(size)-unit(32), input::bytes>>) do
      value = transform2(size, 32, value)
      { DataWrapper.new(:float_array, value), input }
    end

    def decode(<<15, size::size(16), value::binary-size(size)-unit(64), input::bytes>>) do
      value = transform2(size, 64, value)
      { DataWrapper.new(:double_array, value), input }
    end

    def decode(<<16, size::size(16), input::bytes>>) do
      { value, input } = transform3(size, input)
      { DataWrapper.new(:string_array, value), input }
    end

    def decode(<<17, size::size(16), input::bytes>>) do
      { value, input } = transform4(size, input)
      { DataWrapper.new(:array, value), input }
    end

    def decode(<<18, size::size(16), input::bytes>>) do
      { data, input } = decode_map(%{}, size, input)
      { DataWrapper.new(:object, SFSObject.new(data)), input }
    end

    defp decode_map(data, 0, <<input::bytes>>) do
      { data, input }
    end

    defp decode_map(data, size, <<key_length::size(16), key::binary-size(key_length), input::bytes>>) do
      { value, input } = decode(input)
      data = Map.put(data, key, value)
      decode_map(data, size - 1, input)
    end

    def decode_bool(1), do: true
    def decode_bool(0), do: false

    defp transform(size, bit_size, input, acc \\ [])
    defp transform(0, _, _, acc), do: acc
    defp transform(size, bit_size, input, acc) do
      <<val::integer-signed-size(bit_size), input::binary>> = input
      transform(size - 1, bit_size, input, acc ++ [ val ])
    end

    defp transform2(size, bit_size, input, acc \\ [])
    defp transform2(0, _, _, acc), do: acc
    defp transform2(size, bit_size, input, acc) do
      <<val::float-signed-size(bit_size), input::binary>> = input
      transform2(size - 1, bit_size, input, acc ++ [ val ])
    end

    defp transform3(size, input, acc \\ [])
    defp transform3(0, input, acc), do: { acc, input }
    defp transform3(size, input, acc) do
      <<bit_size::signed-size(16), val::binary-size(bit_size), input::binary>> = input
      transform3(size - 1, input, acc ++ [ val ])
    end

    defp transform4(size, input, acc \\ [])
    defp transform4(0, input, acc), do: { acc, input }
    defp transform4(size, input, acc) do
      { val, input } = decode(input)
      transform4(size - 1, input, acc ++ [ val ])
    end
  end
end
