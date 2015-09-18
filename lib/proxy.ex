defmodule Proxy do
  def start do
    start(9944, 9933)
  end

  def start(sport, dport) do
    listen(sport, dport)
  end

  def listen(sport, dport) do
    IO.inspect listen: sport
    tcp_options = [:binary, {:packet, 0}, {:active, false}, {:reuseaddr, true}]
    {:ok, l_socket} = :gen_tcp.listen(sport, tcp_options)
    do_listen(l_socket, dport)
  end

  defp do_listen(l_socket, dport) do
    {:ok, socket} = :gen_tcp.accept(l_socket)
    start_relay(socket, connect_to_remote(dport))

    do_listen(l_socket, dport)
  end

  defp start_relay(local, remote) do
    spawn(fn -> do_relay(local, remote, <<>>) end)
    spawn(fn -> do_relay(remote, local, <<>>) end)
  end

  defp do_relay(socket, remote, rest) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        rest = start_parse_data(rest <> data)
        :gen_tcp.send(remote, data)
        do_relay(socket, remote, rest)
      {:error, :closed} -> :ok
    end
  end

  defp connect_to_remote(dport) do
    tcp_options = [:binary, {:packet, 0}, {:active, false}, {:reuseaddr, true}]
    {:ok, remote} = :gen_tcp.connect('127.0.0.1', dport, tcp_options)
    remote
  end

  def start_parse_data(data) do
    parse_data(data)
  end

  defp parse_data(<<>>) do
    <<>>
  end

  defp parse_data(<<128, size::size(16), data::binary-size(size), rest::binary>>) do
    decode_object(data)
    parse_data(rest)
  end

  defp parse_data(<<160, size::unsigned-size(16), data::binary-size(size), rest::binary>>) do
    plain = :zlib.uncompress(data)
    decode_object(plain)
    parse_data(rest)
  end

  defp parse_data(<<60, 112, 111, rest::binary>>) do
    IO.puts "cross domain request"
    <<>>
  end

  defp parse_data(<<60, 63, 120, rest::binary>>) do
    IO.puts "cross domain response"
    <<>>
  end

  defp parse_data(data) do
    data
  end

  defp decode_object(<<>>) do
  end

  defp decode_object(data) do
    try do
      {object, rest} = SFSObject.DataWrapper.Decoder.decode(data)
      #IO.inspect object
      decode_object(rest)
    rescue
      e ->
        IO.puts "ERROR"
        IO.inspect self
        IO.puts("error: #{data |> inspect_long}")
        raise e
    end
  end

  def inspect_long(data) do
    Inspect.BitString.inspect(data, %Inspect.Opts{limit: 100000})
  end

end
