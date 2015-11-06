defmodule PlugRc.Connections.EventStream do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def connect(conn) do
    IO.puts "---> adding a child  <----"
    Supervisor.start_child(__MODULE__, [conn])
  end

  def init(:ok) do
    supervise([
      worker(EventStream, [], restart: :temporary)
    ], strategy: :simple_one_for_one)
  end
end
