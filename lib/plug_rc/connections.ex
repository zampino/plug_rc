defmodule PlugRc.Connections do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    child_specs = [
      worker(PlugRc.Connections.Registry, [])
    ]
    supervise(child_specs, strategy: :one_for_one)
  end

  # public API

  def register_remote(conn) do
    GenServer.call PlugRc.Connections.Registry, {:register, :remote, conn}
  end

  def register_controller(conn) do
    GenServer.call PlugRc.Connections.Registry, {:register, :controller, conn}
  end

  def get(id) do
    GenServer.call PlugRc.Connections.Registry, {:get, id}
  end

  def remotes do
    GenServer.call PlugRc.Connections.Registry, :remotes
  end

  def notify(id, event) do
    get(id) |> GenEvent.ack_notify(event)
  end
end
