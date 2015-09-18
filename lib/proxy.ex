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
    spawn(fn -> do_server(local, remote) end)
    spawn(fn -> do_server(remote, local) end)
  end

  defp do_server(socket, remote) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        start_parse_data(data)
        :gen_tcp.send(remote, data)
        do_server(socket, remote)

        {:error, :closed} -> :ok
    end
  end

  defp connect_to_remote(dport) do
    tcp_options = [:binary, {:packet, 0}, {:active, false}, {:reuseaddr, true}]
    {:ok, remote} = :gen_tcp.connect('127.0.0.1', dport, tcp_options)
    remote
  end

  def start_parse_data(data) do
    spawn(fn -> parse_data(data) end)
  end

  defp parse_data(<<>>) do
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

  defp parse_data(data) do
    x = Inspect.BitString.inspect(data, %Inspect.Opts{limit: 100000})
    IO.inspect self
    IO.puts("unknown: #{x}")
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
        x = Inspect.BitString.inspect(data, %Inspect.Opts{limit: 100000})
        IO.inspect self
        IO.puts("error: #{x}")
        raise e
    end
  end
end
