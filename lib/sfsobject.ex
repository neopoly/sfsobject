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

  def put_bool_array(object, key, value) when is_list(value) do
    put_data(object, key, :bool_array, value)
  end

  def get_bool_array(object, key) do
    get_data(object, key, :bool_array)
  end

  def put_byte_array(object, key, value) when is_list(value) do
    put_data(object, key, :byte_array, value)
  end

  def get_byte_array(object, key) do
    get_data(object, key, :byte_array)
  end

  def put_short_array(object, key, value) when is_list(value) do
    put_data(object, key, :short_array, value)
  end

  def get_short_array(object, key) do
    get_data(object, key, :short_array)
  end

  def put_int_array(object, key, value) when is_list(value) do
    put_data(object, key, :int_array, value)
  end

  def get_int_array(object, key) do
    get_data(object, key, :int_array)
  end

  def put_long_array(object, key, value) when is_list(value) do
    put_data(object, key, :long_array, value)
  end

  def get_long_array(object, key) do
    get_data(object, key, :long_array)
  end

  def put_float_array(object, key, value) when is_list(value) do
    put_data(object, key, :float_array, value)
  end

  def get_float_array(object, key) do
    get_data(object, key, :float_array)
  end

  def put_double_array(object, key, value) when is_list(value) do
    put_data(object, key, :double_array, value)
  end

  def get_double_array(object, key) do
    get_data(object, key, :double_array)
  end

  def put_string_array(object, key, value) when is_list(value) do
    put_data(object, key, :string_array, value)
  end

  def get_string_array(object, key) do
    get_data(object, key, :string_array)
  end

  def put_array(object, key, value) when is_list(value) do
    put_data(object, key, :array, value)
  end

  def get_array(object, key) do
    get_data(object, key, :array)
  end

  def put_object(object, key, %SFSObject{} = value) do
    put_data(object, key, :object, value)
  end

  def get_object(object, key) do
    get_data(object, key, :object)
  end

  # TODO CLASS(19);

  def wrap(type, value) do
    SFSObject.DataWrapper.new(type, value)
  end

  defp put_data(%SFSObject{data: data} = object, key, type, value) do
    data = Map.put(data, key, wrap(type, value))
    %{object | data: data}
  end

  defp get_data(%SFSObject{data: data}, key, type) do
    case Map.fetch(data, key) do
      {:ok, %SFSObject.DataWrapper{type: ^type, value: value}} -> value
      _ -> nil
    end
  end
end
