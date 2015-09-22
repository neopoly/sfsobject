defmodule SFSObject.Data.Macro do
  defmacro defdata(name) do
    quote do
      defmodule unquote(name) do
        defstruct [:v]

        def new(v) do
          %__MODULE__{v: v}
        end
      end
    end
  end
end

defmodule SFSObject.Data do
  import SFSObject.Data.Macro

  defmodule Null do
    defstruct []
    def type, do: %__MODULE__{}
    def new, do: %__MODULE__{}
  end

  defdata Bool
  defdata Byte
  defdata Short
  defdata Int
  defdata Long
  defdata Float
  defdata Double
  defdata String

  defdata BoolArray
  defdata ByteArray
  defdata ShortArray
  defdata IntArray
  defdata LongArray
  defdata FloatArray
  defdata DoubleArray
  defdata StringArray

  defdata Array
  defdata Object
end

defmodule SFSObject.Data.Coder.Binary do
  alias SFSObject.Data

  def encode(%Data.Null{}) do
    <<0>>
  end
  def decode(<<0>>) do
    Data.Null.new
  end

  def encode(%Data.Bool{v: v}) do
    x = if v do 1 else 0 end
    <<1, x>>
  end
  def decode(<<1, 1>>), do: Data.Bool.new(true)
  def decode(<<1, 0>>), do: Data.Bool.new(false)

  def encode(%Data.Byte{v: v}) do
    <<2, v::signed-size(8)>>
  end
  def decode(<<2, v::signed-size(8)>>), do: Data.Byte.new(v)

  def encode(%Data.String{v: v}) do
    <<8, byte_size(v)::size(16), v::binary>>
  end
  def decode(<<8, size::size(16), v::binary-size(size)>>), do: Data.String.new(v)
end
