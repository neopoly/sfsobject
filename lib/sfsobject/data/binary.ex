defmodule SFSObject.Data.Binary do
  defmodule Encoder do
    alias SFSObject.Data

    def encode(data_wrapper, output \\ <<>>)
    def encode(%Data.Null{}, output) do
      output <> <<0>>
    end

    def encode(%Data.Bool{v: v}, output) do
      output <> <<1, encode_bool(v)>>
    end

    def encode(%Data.Byte{v: v}, output) do
      output <> <<2, v::signed-size(8)>>
    end

    def encode(%Data.Short{v: v}, output) do
      output <> <<3, v::signed-size(16)>>
    end

    def encode(%Data.Int{v: v}, output) do
      output <> <<4, v::signed-size(32)>>
    end

    def encode(%Data.Long{v: v}, output) do
      output <> <<5, v::signed-size(64)>>
    end

    def encode(%Data.Float{v: v}, output) do
      output <> <<6, v::float-signed-size(32)>>
    end

    def encode(%Data.Double{v: v}, output) do
      output <> <<7, v::float-signed-size(64)>>
    end

    def encode(%Data.String{v: v}, output) do
      size = byte_size(v)
      output <> <<8, size::size(16), v::binary>>
    end

    def encode(%Data.BoolArray{v: v}, output) do
      size = length(v)
      data = v |> Enum.map(&encode_bool/1) |> IO.iodata_to_binary
      output <> <<9, size::size(16), data::binary>>
    end

    def encode(%Data.ByteArray{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> <<e::signed-size(8)>> end)
        |> IO.iodata_to_binary
      output <> <<10, size::size(32), data::binary>>
    end

    def encode(%Data.ShortArray{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> <<e::signed-size(16)>> end)
        |> IO.iodata_to_binary
      output <> <<11, size::size(16), data::binary>>
    end

    def encode(%Data.IntArray{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> <<e::signed-size(32)>> end)
        |> IO.iodata_to_binary
      output <> <<12, size::size(16), data::binary>>
    end

    def encode(%Data.LongArray{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> <<e::signed-size(64)>> end)
        |> IO.iodata_to_binary
      output <> <<13, size::size(16), data::binary>>
    end

    def encode(%Data.FloatArray{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> <<e::float-signed-size(32)>> end)
        |> IO.iodata_to_binary
      output <> <<14, size::size(16), data::binary>>
    end

    def encode(%Data.DoubleArray{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> <<e::float-signed-size(64)>> end)
        |> IO.iodata_to_binary
      output <> <<15, size::size(16), data::binary>>
    end

    def encode(%Data.StringArray{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> <<byte_size(e)::signed-size(16),e::binary>> end)
        |> IO.iodata_to_binary
      output <> <<16, size::size(16), data::binary>>
    end

    def encode(%Data.Array{v: v}, output) do
      size = length(v)
      data = v
        |> Enum.map(fn(e) -> encode(e) end)
        |> IO.iodata_to_binary
      output <> <<17, size::size(16), data::binary>>
    end

    def encode(%Data.Object{v: v}, output) do
      size = Map.size(v)
      data = v
        |> Enum.flat_map(fn({key, v}) ->
            [ encode_key(key), encode(v) ]
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
    alias SFSObject.Data

    def decode(<<0, input::bytes>>) do
      { %Data.Null{}, input }
    end

    def decode(<<1, v, input::bytes>>) do
      { %Data.Bool{v: 1 == v}, input }
    end

    def decode(<<2, v::signed-size(8), input::bytes>>) do
      { %Data.Byte{v: v}, input }
    end

    def decode(<<3, v::signed-size(16), input::bytes>>) do
      { %Data.Short{v: v}, input }
    end

    def decode(<<4, v::signed-size(32), input::bytes>>) do
      { %Data.Int{v: v}, input }
    end

    def decode(<<5, v::signed-size(64), input::bytes>>) do
      { %Data.Long{v: v}, input }
    end

    def decode(<<6, v::float-signed-size(32), input::bytes>>) do
      { %Data.Float{v: v}, input }
    end

    def decode(<<7, v::float-signed-size(64), input::bytes>>) do
      { %Data.Double{v: v}, input }
    end

    def decode(<<8, size::size(16), v::binary-size(size), input::bytes>>) do
      { %Data.String{v: v}, input }
    end

    def decode(<<9, size::size(16), v::binary-size(size), input::bytes>>) do
      v = v |> to_char_list |> Enum.map(&decode_bool/1)
      { %Data.BoolArray{v: v}, input }
    end

    def decode(<<10, size::size(32), v::binary-size(size), input::bytes>>) do
      v = transform(size, 8, v)
      { %Data.ByteArray{v: v}, input }
    end

    def decode(<<11, size::size(16), v::binary-size(size)-unit(16), input::bytes>>) do
      v = transform(size, 16, v)
      { %Data.ShortArray{v: v}, input }
    end

    def decode(<<12, size::size(16), v::binary-size(size)-unit(32), input::bytes>>) do
      v = transform(size, 32, v)
      { %Data.IntArray{v: v}, input }
    end

    def decode(<<13, size::size(16), v::binary-size(size)-unit(64), input::bytes>>) do
      v = transform(size, 64, v)
      { %Data.LongArray{v: v}, input }
    end

    def decode(<<14, size::size(16), v::binary-size(size)-unit(32), input::bytes>>) do
      v = transform2(size, 32, v)
      { %Data.FloatArray{v: v}, input }
    end

    def decode(<<15, size::size(16), v::binary-size(size)-unit(64), input::bytes>>) do
      v = transform2(size, 64, v)
      { %Data.DoubleArray{v: v}, input }
    end

    def decode(<<16, size::size(16), input::bytes>>) do
      { v, input } = transform3(size, input)
      { %Data.StringArray{v: v}, input }
    end

    def decode(<<17, size::size(16), input::bytes>>) do
      { v, input } = transform4(size, input)
      { %Data.Array{v: v}, input }
    end

    def decode(<<18, size::size(16), input::bytes>>) do
      { data, input } = decode_map(%{}, size, input)
      { %Data.Object{v: SFSObject.new(data)}, input }
    end

    defp decode_map(data, 0, <<input::bytes>>) do
      { data, input }
    end

    defp decode_map(data, size, <<key_length::size(16), key::binary-size(key_length), input::bytes>>) do
      { v, input } = decode(input)
      data = Map.put(data, key, v)
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
