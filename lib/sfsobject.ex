defmodule SFSObject do
  defstruct data: %{}

  defmodule DataWrapper do
    defstruct [:type, :value]

    def new(type, value) do
      %DataWrapper{type: type, value: value}
    end
  end

  def new() do
    %SFSObject{}
  end

  def put_null(object, key) do
    put_data(object, key, :null, :null)
  end

  def is_null?(object, key) do
    get_data(object, key, :null) == :null
  end

  def put_bool(object, key, value) when is_boolean(value) do
    put_data(object, key, :bool, value)
  end

  def get_bool(object, key) do
    get_data(object, key, :bool)
  end

  def put_byte(object, key, value) when is_integer(value) do
    put_data(object, key, :byte, value)
  end

  def get_byte(object, key) do
    get_data(object, key, :byte)
  end

  def put_short(object, key, value) when is_integer(value) do
    put_data(object, key, :short, value)
  end

  def get_short(object, key) do
    get_data(object, key, :short)
  end

  def put_int(object, key, value) when is_integer(value) do
    put_data(object, key, :int, value)
  end

  def get_int(object, key) do
    get_data(object, key, :int)
  end

  def put_long(object, key, value) when is_number(value) do
    put_data(object, key, :long, value)
  end

  def get_long(object, key) do
    get_data(object, key, :long)
  end

  def put_float(object, key, value) when is_float(value) do
    put_data(object, key, :float, value)
  end

  def get_float(object, key) do
    get_data(object, key, :float)
  end

  def put_double(object, key, value) when is_float(value) do
    put_data(object, key, :double, value)
  end

  def get_double(object, key) do
    get_data(object, key, :double)
  end

  def put_string(object, key, value) when is_binary(value) do
    put_data(object, key, :string, value)
  end

  def get_string(object, key) do
    get_data(object, key, :string)
  end

  # BOOL_ARRAY(9),
  # BYTE_ARRAY(10),
  # SHORT_ARRAY(11),
  # INT_ARRAY(12),
  # LONG_ARRAY(13),
  # FLOAT_ARRAY(14),
  # DOUBLE_ARRAY(15),
  # UTF_STRING_ARRAY(16),
  # SFS_ARRAY(17),
  # SFS_OBJECT(18),
  # CLASS(19);

  defp put_data(%SFSObject{data: data} = object, key, type, value) do
    wrapped = SFSObject.DataWrapper.new(type, value)
    data = Map.put(data, key, wrapped)
    %{object | data: data}
  end

  defp get_data(%SFSObject{data: data}, key, type) do
    case Map.fetch(data, key) do
      {:ok, %SFSObject.DataWrapper{type: ^type, value: value}} -> value
      _ -> nil
    end
  end
end
