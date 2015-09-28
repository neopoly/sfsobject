defmodule SFSObject.Binary.Encoder do
  import SFSObject.Binary.Macro

  def encode(data_wrapper, output \\ <<>>)

  defencode :null, [0]
  defencode :bool, [1, encode_bool(v)]
  defencode :byte, [2, v::signed-size(8)]
  defencode :short, [3, v::signed-size(16)]
  defencode :int, [4, v::signed-size(32)]
  defencode :long, [5, v::signed-size(64)]
  defencode :float, [6, v::float-signed-size(32)]
  defencode :double, [7, v::float-signed-size(64)]
  defencode :string, [8, byte_size(v)::size(16), v::binary]

  defencode :bool_array, [9, length(v)::size(16)] do
    [encode_bool(val)::size(8)]
  end

  defencode :byte_array, [10, length(v)::size(32)] do
    [val::signed-size(8)]
  end

  defencode :short_array, [11, length(v)::size(16)] do
    [val::signed-size(16)]
  end

  defencode :int_array, [12, length(v)::size(16)] do
    [val::signed-size(32)]
  end

  defencode :long_array, [13, length(v)::size(16)] do
    [val::signed-size(64)]
  end

  defencode :float_array, [14, length(v)::size(16)] do
    [val::float-signed-size(32)]
  end

  defencode :double_array, [15, length(v)::size(16)] do
    [val::float-signed-size(64)]
  end

  defencode :string_array, [16, length(v)::size(16)] do
    [byte_size(val)::signed-size(16),val::binary]
  end

  defencode :array, [17, length(v)::size(16)] do
    [encode(val, <<>>)::binary]
  end

  defencode :object, [18, Map.size(v)::size(16)] do
    [encode_kv(val)::binary]
  end

  defp encode_kv({key, value}) do
    <<String.length(key)::size(16), key::binary, encode(value)::binary>>
  end

  defp encode_bool(true), do: 1
  defp encode_bool(false), do: 0

  defp transform(_, [], output), do: output
  defp transform(:object, %{} = value, output) do
    transform(:object, Map.to_list(value), output)
  end
end
