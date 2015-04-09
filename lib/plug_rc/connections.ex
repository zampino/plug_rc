defmodule PlugRc.Connections do

  def register(id, conn) do
    {:ok, pid } = GenServer.call PlugRc.Connections.Registry, {:register, id}
    GenEvent.add_mon_handler pid, PlugRc.Connections.EventHandler, conn
    {:ok, pid}
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

end
