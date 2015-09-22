defmodule SFSObject.Data.Macro do
  defmacro defdata(name) do
    quote do
      defmodule unquote(name) do
        defstruct [:v]
      end
    end
  end
end

defmodule SFSObject.Data do
  import SFSObject.Data.Macro

  defmodule Null do
    defstruct []
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
