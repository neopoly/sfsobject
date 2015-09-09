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

    def encode(%DataWrapper{type: :bool, value: true}, <<output::bytes>>) do
      [ output | <<1, 1>> ]
    end

    def encode(%DataWrapper{type: :bool, value: false}, <<output::bytes>>) do
      [ output | <<1, 0>> ]
    end

    def encode(%SFSObject{data: data}, <<output::bytes>>) do
      [ output | encode_map(data) ]
    end

    def encode(%DataWrapper{type: :sfsobject, value: %SFSObject{data: data}}, <<output::bytes>>) do
      [ output | encode_map(data) ]
    end

    defp encode_map(%{} = data) do
      type = 18
      size = Map.size(data)
      data = Enum.flat_map(data, fn({key, value}) ->
        [ encode_key(key), encode(value) ]
      end)

      [ <<type, size::16>> | data ]
    end

    defp encode_key(key) do
      <<String.length(key)::16, key::binary>>
    end
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

    def decode(<<18, size::16, input::bytes>>) do
      { data, input } = decode_map(%{}, size, input)
      { SFSObject.new(data), input }
    end

    defp decode_map(data, 0, <<input::bytes>>) do
      { data, input }
    end

    defp decode_map(data, size, <<key_length::16, key::binary-size(key_length), input::bytes>>) do
      { value, input } = decode(input)
      data = Map.put(data, key, value)
      decode_map(data, size - 1, input)
    end
  end
end
