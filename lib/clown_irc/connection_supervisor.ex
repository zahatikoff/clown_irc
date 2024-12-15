defmodule ClownIRC.ConnectionSupervisor do
  use Supervisor
  require Logger

  def init(default_connections) do
    Logger.debug("Starting ConnSup")

    children = [
      {ClownIRC.ConnectionManager, {self(), default_connections}}
    ]

    sup_flags = [strategy: :rest_for_one]

    Supervisor.init(children, sup_flags)
  end

  def child_spec(args) do
    %{
      id: :conn_sup,
      start: [
        Supervisor,
        :start_link,
        [__MODULE__, args, [strategy: :rest_for_one]]
      ],
      restart: :permanent,
      type: :supervisor
    }
  end
end
