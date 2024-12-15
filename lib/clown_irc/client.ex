defmodule IRC.Client do
  use GenServer
  require Logger
  alias :gen_tcp, as: Tcp

  @impl true
  @spec init(conn :: %IRC.Conn{}) ::
          {:ok, {conn :: IRC.Conn.t(), socket :: :inet.socket()}}
          | {:error, atom}

  def init(conn = %IRC.Conn{}) do
    Logger.debug("Trying to connect to #{conn.server}")

    with {:ok, socket} <-
           Tcp.connect(~c"#{conn.server}", conn.port, [:binary, packet: :line, active: true]) do
      Logger.debug("Connection successfull,Starting packet send")

      Tcp.send(socket, "CAP LS 302\r\n")

      if conn.password !== "" do
        Tcp.send(socket, "PASS #{conn.password}\r\n")
      end

      Tcp.send(socket, "NICK #{conn.nick}\r\n")
      Tcp.send(socket, "USER #{conn.nick} 0 * :Zaha's bot\r\n")

      Tcp.send(socket, "CAP END\r\n")
      {:ok, {conn, socket}}
    else
      {:error, reason} ->
        Logger.error("Connection failed with #{reason}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_info({:tcp, socket, message}, state = {_conn, socket}) do
    Logger.debug("#{message}")
    Logger.info("#{inspect(IRC.Parser.parse!(message))}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, state = {conn, socket}) do
    Logger.warning("Closing connection #{inspect(conn)}")
    {:stop, :normal, state}
  end

  @impl true
  def handle_call(:close, _from, state = {_conn, socket}) do
    Tcp.close(socket)
    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_cast({:send, message}, state = {_conn, socket}) do
    Tcp.send(socket, message)
    {:stop, :normal, state}
  end

  def child_spec(conn) when is_struct(conn, IRC.Conn) do
    %{
      id: conn.server,
      start: {
        GenServer,
        :start_link,
        [__MODULE__, conn]
      },
      restart: :transient,
      type: :worker
    }
  end
end
