defmodule PlugRc.Connections do
  # public api

  def register(id) do
    GenServer.call PlugRc.Connections.Registry, {:register, id}
  end

  def get(id) do
    GenServer.call PlugRc.Connections.Registry, {:get, id}
  end

  def all do
    GenServer.call PlugRc.Connections.Registry, :all
  end

  def notify_of(manager, body) do
    event = %{type: body["type"], which: body["which"]}
    GenEvent.ack_notify manager, event
  end

  def ping(id) do
    notify_of get(id), %{"type" => "ping"}
  end

end
