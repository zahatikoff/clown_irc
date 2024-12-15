defmodule ClownIRC.ConnectionPool do
  use DynamicSupervisor

  def child_spec(num) when is_number(num) do
    %{
      id: "IRC Connection Pool ##{num}",
      start: {
        DynamicSupervisor,
        :start_link,
        [__MODULE__, num]
      },
      restart: :permanent,
      shutdown: 1000,
      type: :supervisor
    }
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
