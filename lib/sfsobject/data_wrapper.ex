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
  end

  defmodule Decoder do
    alias SFSObject.DataWrapper

    def decode(<< 0, input::bytes >>) do
      { DataWrapper.new(:null, :null), input }
    end

    def decode(<< 1, 1, input::bytes >>) do
      { DataWrapper.new(:bool, true), input }
    end

    def decode(<< 1, 0, input::bytes >>) do
      { DataWrapper.new(:bool, false), input }
    end
  end
end
