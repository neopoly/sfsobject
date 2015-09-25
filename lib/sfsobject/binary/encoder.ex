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
    data = transform(v, output, fn val -> <<val::signed-size(8)>> end)
    output <> <<10, size::size(32), data::binary>>
  end

  def encode({:short_array, v}, output) do
    size = length(v)
    data = transform(v, output, fn val -> <<val::signed-size(16)>> end)
    output <> <<11, size::size(16), data::binary>>
  end

  def encode({:int_array, v}, output) do
    size = length(v)
    data = transform(v, output, fn val -> <<val::signed-size(32)>> end)
    output <> <<12, size::size(16), data::binary>>
  end

  def encode({:long_array, v}, output) do
    size = length(v)
    data = transform(v, output, fn val -> <<val::signed-size(64)>> end)
    output <> <<13, size::size(16), data::binary>>
  end

  def encode({:float_array, v}, output) do
    size = length(v)
    data = transform(v, output, fn val -> <<val::float-signed-size(32)>> end)
    output <> <<14, size::size(16), data::binary>>
  end

  def encode({:double_array, v}, output) do
    size = length(v)
    data = transform(v, output, fn val -> <<val::float-signed-size(64)>> end)
    output <> <<15, size::size(16), data::binary>>
  end

  def encode({:string_array, v}, output) do
    size = length(v)
    data = transform(v, output, fn val -> <<byte_size(val)::signed-size(16),val::binary>> end)
    output <> <<16, size::size(16), data::binary>>
  end

  def encode({:array, v}, output) do
    size = length(v)
    data = transform(v, output, fn val -> encode(val, output) end)
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

  defp transform([], output, _fun), do: output
  defp transform([val|rest], output, fun) do
    transform(rest, output <> fun.(val), fun)
  end

  defp transform5([], output), do: output
  defp transform5([{key, val}|rest], output) do
    transform5(rest, output <> encode_key(key) <> encode(val) )
  end
end
