defmodule SFSObject.Binary.Encoder do
  def encode(data_wrapper, output \\ <<>>)
  def encode({:null, _}, output) do
    output <> <<0>>
  end

  def encode({:bool, v}, output) do
    output <> <<1, encode_bool(v)>>
  end

  def encode({:byte, v}, output) do
    output <> <<2, v::signed-size(8)>>
  end

  def encode({:short, v}, output) do
    output <> <<3, v::signed-size(16)>>
  end

  def encode({:int, v}, output) do
    output <> <<4, v::signed-size(32)>>
  end

  def encode({:long, v}, output) do
    output <> <<5, v::signed-size(64)>>
  end

  def encode({:float, v}, output) do
    output <> <<6, v::float-signed-size(32)>>
  end

  def encode({:double, v}, output) do
    output <> <<7, v::float-signed-size(64)>>
  end

  def encode({:string, v}, output) do
    size = byte_size(v)
    output <> <<8, size::size(16), v::binary>>
  end

  def encode({:bool_array, v}, output) do
    size = length(v)
    data = v |> Enum.map(&encode_bool/1) |> IO.iodata_to_binary
    output <> <<9, size::size(16), data::binary>>
  end

  def encode({:byte_array, v}, output) do
    size = length(v)
    data = transform(v, 8, output)
    output <> <<10, size::size(32), data::binary>>
  end

  def encode({:short_array, v}, output) do
    size = length(v)
    data = transform(v, 16, output)
    output <> <<11, size::size(16), data::binary>>
  end

  def encode({:int_array, v}, output) do
    size = length(v)
    data = transform(v, 32, output)
    output <> <<12, size::size(16), data::binary>>
  end

  def encode({:long_array, v}, output) do
    size = length(v)
    data = transform(v, 64, output)
    output <> <<13, size::size(16), data::binary>>
  end

  def encode({:float_array, v}, output) do
    size = length(v)
    data = transform2(v, 32, output)
    output <> <<14, size::size(16), data::binary>>
  end

  def encode({:double_array, v}, output) do
    size = length(v)
    data = transform2(v, 64, output)
    output <> <<15, size::size(16), data::binary>>
  end

  def encode({:string_array, v}, output) do
    size = length(v)
    data = transform3(v, 16, output)
    output <> <<16, size::size(16), data::binary>>
  end

  def encode({:array, v}, output) do
    size = length(v)
    data = transform4(v, output)
    output <> <<17, size::size(16), data::binary>>
  end

  def encode({:object, v}, output) do
    size = Map.size(v)
    data = transform5(Map.to_list(v), output)
    output <> <<18, size::size(16), data::binary>>
  end

  defp encode_key(key) do
    <<String.length(key)::size(16), key::binary>>
  end

  defp encode_bool(true), do: 1
  defp encode_bool(false), do: 0

  defp transform([], _, output), do: output
  defp transform([val|rest], bit_size, output) do
    transform(rest, bit_size, output <> <<val::signed-size(bit_size)>>)
  end

  defp transform2([], _, output), do: output
  defp transform2([val|rest], bit_size, output) do
    transform2(rest, bit_size, output <> <<val::float-signed-size(bit_size)>>)
  end

  defp transform3([], _, output), do: output
  defp transform3([val|rest], bit_size, output) do
    transform3(rest, bit_size,
      output <> <<byte_size(val)::signed-size(bit_size),val::binary>>)
  end

  defp transform4([], output), do: output
  defp transform4([val|rest], output) do
    transform4(rest, encode(val, output))
  end

  defp transform5([], output), do: output
  defp transform5([{key, val}|rest], output) do
    transform5(rest, output <> encode_key(key) <> encode(val) )
  end
end
