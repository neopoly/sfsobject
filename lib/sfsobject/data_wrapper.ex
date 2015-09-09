defmodule SFSObject.DataWrapper do
  defstruct [:type, :value]

  def new(type, value) do
    %__MODULE__{type: type, value: value}
  end

  defmodule Encoder do
    alias SFSObject.DataWrapper

    def encode(data_wrapper) do
      encode(data_wrapper, <<>>)
    end

    def encode(%DataWrapper{type: :null}, <<output::bytes>>) do
      [ output | <<0>> ]
    end

    def encode(%DataWrapper{type: :bool, value: value}, <<output::bytes>>) do
      [ output | <<1, encode_bool(value)>> ]
    end

    def encode(%DataWrapper{type: :byte, value: value}, <<output::bytes>>) do
      [ output | <<2, value::signed-size(8)>> ]
    end

    def encode(%DataWrapper{type: :short, value: value}, <<output::bytes>>) do
      [ output | <<3, value::signed-size(16)>> ]
    end

    def encode(%DataWrapper{type: :int, value: value}, <<output::bytes>>) do
      [ output | <<4, value::signed-size(32)>> ]
    end

    def encode(%DataWrapper{type: :long, value: value}, <<output::bytes>>) do
      [ output | <<5, value::signed-size(64)>> ]
    end

    def encode(%DataWrapper{type: :float, value: value}, <<output::bytes>>) do
      [ output | <<6, value::float-signed-size(32)>> ]
    end

    def encode(%DataWrapper{type: :double, value: value}, <<output::bytes>>) do
      [ output | <<7, value::float-signed-size(64)>> ]
    end

    def encode(%DataWrapper{type: :string, value: value}, <<output::bytes>>) do
      size = byte_size(value)
      [ output | <<8, size::size(16), value::binary>> ]
    end

    def encode(%DataWrapper{type: :bool_array, value: value}, <<output::bytes>>) do
      size = length(value)
      data = value |> Enum.map(&encode_bool/1) |> IO.iodata_to_binary
      [ output | <<9, size::size(16), data::binary>> ]
    end

    def encode(%DataWrapper{type: :byte_array, value: value}, <<output::bytes>>) do
      size = length(value)
      data = value
        |> Enum.map(fn(e) -> <<e::signed-size(8)>> end)
        |> IO.iodata_to_binary
      [ output | <<10, size::size(32), data::binary>> ]
    end

    def encode(%DataWrapper{type: :object, value: %SFSObject{data: data}}, <<output::bytes>>) do
      [ output | encode_map(data) ]
    end

    defp encode_map(%{} = data) do
      type = 18
      size = Map.size(data)
      data = Enum.flat_map(data, fn({key, value}) ->
        [ encode_key(key), encode(value) ]
      end)

      [ <<type, size::size(16)>> | data ]
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
      value = transform(:byte, size, value)
      { DataWrapper.new(:byte_array, value), input }
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

    defp transform(type, size, pattern) do
      transform(type, size, pattern, [])
    end

    defp transform(_, 0, _, acc), do: acc
    defp transform(:byte, size, <<val::signed-size(8), input::binary>>, acc) do
      transform(:byte, size - 1, input, acc ++ [ val ])
    end
  end
end
