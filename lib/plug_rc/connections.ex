defmodule PlugRc.Connections do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    child_specs = [
      supervisor(PlugRc.Connections.EventStream, []),
      worker(PlugRc.Connections.Registry, [])
    ]
    supervise(child_specs, strategy: :one_for_one)
  end

  # public API

  def register(conn) do
    GenServer.call PlugRc.Connections.Registry, {:register, conn}
  end

  def register_manager(conn) do
    Genserver.call PlugRc.Connections.Registry, {:register, :manager, conn}
  end

  def get(id) do
    GenServer.call PlugRc.Connections.Registry, {:get, id}
  end

  def all do
    GenServer.call PlugRc.Connections.Registry, :all
  end

  def notify(id, event) do
    get(id) |> GenEvent.ack_notify(event)
  end


  # supervisor

end
