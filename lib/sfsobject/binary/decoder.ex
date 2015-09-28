defmodule SFSObject.Binary.Macro2 do
  defmacro defdecode(name, format, to: to) do
    quote do
      def decode(<<unquote_splicing(format), input::bytes>>) do
        {{unquote(name), unquote(to)}, input}
      end
    end
  end
end

defmodule SFSObject.Binary.Decoder do
  import SFSObject.Binary.Macro2

  defdecode :null, [0], to: :null
  defdecode :bool, [1, v], to: v == 1
  defdecode :byte, [2, v::signed-size(8)], to: v
  defdecode :short, [3, v::signed-size(16)], to: v
  defdecode :int, [4, v::signed-size(32)], to: v
  defdecode :long, [5, v::signed-size(64)], to: v
  defdecode :float, [6, v::float-signed-size(32)], to: v
  defdecode :double, [7, v::float-signed-size(64)], to: v
  defdecode :string, [8, size::size(16), v::binary-size(size)], to: v

  def decode(<<9, size::size(16), v::binary-size(size), input::bytes>>) do
    fun = fn input -> <<val, rest::binary>> = input; {val == 1, rest} end
    {v, _} = transform(size, v, fun)
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

  defp transform(size, input, fun, acc \\ [])
  defp transform(0, input, _, acc), do: {acc, input}
  defp transform(size, input, fun, acc) do
    {val, rest} = fun.(input)
    transform(size - 1, rest, fun, accumulate(acc, val))
  end

  defp accumulate(acc, val) when is_list(acc), do: acc ++ [val]
  defp accumulate(acc, {key, val}) when is_map(acc), do: Map.put(acc, key, val)
end
