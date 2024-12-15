defmodule ClownIRC.ConnectionManager do
  use GenServer
  require Logger

  @typep args() :: {
           connlist :: [IRC.Conn.t()],
           parent_sup :: pid(),
           pool_sup :: pid() | nil
         }

  @spec init({parent_sup :: pid(), connlist :: [IRC.Conn.t()]}) ::
          {:ok, args :: args()}

  def init({parent_sup, connlist}) when is_pid(parent_sup) and is_list(connlist) do
    Logger.debug("Starting ConnMgr")
    send(self(), :start)
    {:ok, {connlist, parent_sup, nil}}
  end

  def handle_cast({:add, conn}, {connlist, parent_sup, pool_sup}) do
    case DynamicSupervisor.start_child(pool_sup, {IRC.Client, conn}) do
      {:ok, _} -> {:noreply, {[connlist | conn], parent_sup, pool_sup}}
      {:ok, _, _} -> {:noreply, {[connlist | conn], parent_sup, pool_sup}}
      {:error, reason} -> {:stop, reason}
      :ignore -> {:stop, :ignore}
    end
  end

  def handle_info(:start, {connlist, parent_sup, _}) do
    Logger.debug("Starting ConnPool")

    case Supervisor.start_child(parent_sup, {ClownIRC.ConnectionPool, 0}) do
      {:ok, :undefined} ->
        {:stop, "Pool not started"}

      {:ok, pid} when is_pid(pid) ->
        Logger.debug("#{inspect(pid)}")
        {:noreply, {connlist, parent_sup, pid}}

      {:ok, pid, info} when is_pid(pid) ->
        Logger.debug("#{inspect(info)}")
        {:noreply, {connlist, parent_sup, pid}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  def child_spec(init_args) do
    %{
      id: :conn_mgr,
      start: {
        GenServer,
        :start_link,
        [__MODULE__, init_args]
      },
      restart: :permanent,
      type: :worker
    }
  end
end
