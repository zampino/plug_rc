defmodule PlugRc.Connections.EventManagers do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add(_id) do
    IO.puts "---> adding a child #{_id} <----"
    Supervisor.start_child(__MODULE__, [])
  end

  def init(:ok) do
    child = [
      worker(GenEvent, [], restart: :temporary)
    ]
    supervise(child, strategy: :simple_one_for_one)
  end
end
