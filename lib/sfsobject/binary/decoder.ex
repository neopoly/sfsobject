defmodule SFSObject.Binary.Decoder do
  def decode(<<0, input::bytes>>) do
    { {:null, :null}, input }
  end

  def decode(<<1, v, input::bytes>>) do
    { {:bool, 1 == v}, input }
  end

  def decode(<<2, v::signed-size(8), input::bytes>>) do
    { {:byte, v}, input }
  end

  def decode(<<3, v::signed-size(16), input::bytes>>) do
    { {:short, v}, input }
  end

  def decode(<<4, v::signed-size(32), input::bytes>>) do
    { {:int, v}, input }
  end

  def decode(<<5, v::signed-size(64), input::bytes>>) do
    { {:long, v}, input }
  end

  def decode(<<6, v::float-signed-size(32), input::bytes>>) do
    { {:float, v}, input }
  end

  def decode(<<7, v::float-signed-size(64), input::bytes>>) do
    { {:double, v}, input }
  end

  def decode(<<8, size::size(16), v::binary-size(size), input::bytes>>) do
    { {:string, v}, input }
  end

  def decode(<<9, size::size(16), v::binary-size(size), input::bytes>>) do
    v = v |> to_char_list |> Enum.map(&decode_bool/1)
    { {:bool_array, v}, input }
  end

  def decode(<<10, size::size(32), v::binary-size(size), input::bytes>>) do
    fun = fn input -> <<val::integer-signed-size(8), rest::binary>> = input; {val, rest} end
    {v, _} = transform(size, v, fun)
    { {:byte_array, v}, input }
  end

  def decode(<<11, size::size(16), v::binary-size(size)-unit(16), input::bytes>>) do
    fun = fn input -> <<val::integer-signed-size(16), rest::binary>> = input; {val, rest} end
    {v, _} = transform(size, v, fun)
    { {:short_array, v}, input }
  end

  def decode(<<12, size::size(16), v::binary-size(size)-unit(32), input::bytes>>) do
    fun = fn input -> <<val::integer-signed-size(32), rest::binary>> = input; {val, rest} end
    {v, _} = transform(size, v, fun)
    { {:int_array, v}, input }
  end

  def decode(<<13, size::size(16), v::binary-size(size)-unit(64), input::bytes>>) do
    fun = fn input -> <<val::integer-signed-size(64), rest::binary>> = input; {val, rest} end
    {v, _} = transform(size, v, fun)
    { {:long_array, v}, input }
  end

  def decode(<<14, size::size(16), v::binary-size(size)-unit(32), input::bytes>>) do
    fun = fn input -> <<val::float-signed-size(32), rest::binary>> = input; {val, rest} end
    {v, _} = transform(size, v, fun)
    { {:float_array, v}, input }
  end

  def decode(<<15, size::size(16), v::binary-size(size)-unit(64), input::bytes>>) do
    fun = fn input -> <<val::float-signed-size(64), rest::binary>> = input; {val, rest} end
    {v, _} = transform(size, v, fun)
    { {:double_array, v}, input }
  end

  def decode(<<16, size::size(16), input::bytes>>) do
    fun = fn input ->
      <<s::signed-size(16), val::binary-size(s), input::binary>> = input
      {val, input}
    end
    {v, input} = transform(size, input, fun)
    { {:string_array, v}, input }
  end

  def decode(<<17, size::size(16), input::bytes>>) do
    fun = fn input -> decode(input) end
    {v, input} = transform(size, input, fun)
    { {:array, v}, input }
  end

  def decode(<<18, size::size(16), input::bytes>>) do
    fun = fn input ->
      <<len::size(16), key::binary-size(len), input::bytes>> = input
      {val, input} = decode(input)
      {{key, val}, input}
    end
    {v, input} = transform(size, input, fun, %{})
    { {:object, SFSObject.new(v)}, input }
  end

  def decode_bool(1), do: true
  def decode_bool(0), do: false

  defp transform(size, input, fun, acc \\ [])
  defp transform(0, input, _, acc), do: {acc, input}
  defp transform(size, input, fun, acc) do
    {val, rest} = fun.(input)
    transform(size - 1, rest, fun, accumulate(acc, val))
  end

  defp accumulate(acc, val) when is_list(acc), do: acc ++ [val]
  defp accumulate(acc, {key, val}) when is_map(acc), do: Map.put(acc, key, val)
end
