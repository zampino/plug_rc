defmodule PlugRc.Connections.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    child_specs = [
      worker(PlugRc.Connections.EventManagers, []),
      worker(PlugRc.Connections.Registry, [])
    ]
    supervise(child_specs, strategy: :one_for_one)
  end

end
