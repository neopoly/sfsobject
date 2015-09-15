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
      { :ok, data } ->
        parse_data(data)
        :gen_tcp.send(remote, data)
        do_server(socket, remote)

        { :error, :closed } -> :ok
    end
  end

  defp connect_to_remote(dport) do
    tcp_options = [:binary, {:packet, 0}, {:active, false}, {:reuseaddr, true}]
    {:ok, remote} = :gen_tcp.connect('127.0.0.1', dport, tcp_options)
    remote
  end

  defp parse_data(<<128, size::size(16), data::binary-size(size), rest::binary>>) do
    {object, <<>>} = SFSObject.DataWrapper.Decoder.decode(data)
    IO.inspect object.value
  end

  defp parse_data(data) do
    IO.inspect unknown: data
  end
end
