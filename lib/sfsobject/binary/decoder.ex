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
    v = transform(size, 8, v)
    { {:byte_array, v}, input }
  end

  def decode(<<11, size::size(16), v::binary-size(size)-unit(16), input::bytes>>) do
    v = transform(size, 16, v)
    { {:short_array, v}, input }
  end

  def decode(<<12, size::size(16), v::binary-size(size)-unit(32), input::bytes>>) do
    v = transform(size, 32, v)
    { {:int_array, v}, input }
  end

  def decode(<<13, size::size(16), v::binary-size(size)-unit(64), input::bytes>>) do
    v = transform(size, 64, v)
    { {:long_array, v}, input }
  end

  def decode(<<14, size::size(16), v::binary-size(size)-unit(32), input::bytes>>) do
    v = transform2(size, 32, v)
    { {:float_array, v}, input }
  end

  def decode(<<15, size::size(16), v::binary-size(size)-unit(64), input::bytes>>) do
    v = transform2(size, 64, v)
    { {:double_array, v}, input }
  end

  def decode(<<16, size::size(16), input::bytes>>) do
    { v, input } = transform3(size, input)
    { {:string_array, v}, input }
  end

  def decode(<<17, size::size(16), input::bytes>>) do
    { v, input } = transform4(size, input)
    { {:array, v}, input }
  end

  def decode(<<18, size::size(16), input::bytes>>) do
    { data, input } = decode_map(%{}, size, input)
    { {:object, SFSObject.new(data)}, input }
  end

  defp decode_map(data, 0, <<input::bytes>>) do
    { data, input }
  end

  defp decode_map(data, size, <<key_length::size(16), key::binary-size(key_length), input::bytes>>) do
    { v, input } = decode(input)
    data = Map.put(data, key, v)
    decode_map(data, size - 1, input)
  end

  def decode_bool(1), do: true
  def decode_bool(0), do: false

  defp transform(size, bit_size, input, acc \\ [])
  defp transform(0, _, _, acc), do: acc
  defp transform(size, bit_size, input, acc) do
    <<val::integer-signed-size(bit_size), input::binary>> = input
    transform(size - 1, bit_size, input, acc ++ [ val ])
  end

  defp transform2(size, bit_size, input, acc \\ [])
  defp transform2(0, _, _, acc), do: acc
  defp transform2(size, bit_size, input, acc) do
    <<val::float-signed-size(bit_size), input::binary>> = input
    transform2(size - 1, bit_size, input, acc ++ [ val ])
  end

  defp transform3(size, input, acc \\ [])
  defp transform3(0, input, acc), do: { acc, input }
  defp transform3(size, input, acc) do
    <<bit_size::signed-size(16), val::binary-size(bit_size), input::binary>> = input
    transform3(size - 1, input, acc ++ [ val ])
  end

  defp transform4(size, input, acc \\ [])
  defp transform4(0, input, acc), do: { acc, input }
  defp transform4(size, input, acc) do
    { val, input } = decode(input)
    transform4(size - 1, input, acc ++ [ val ])
  end
end
