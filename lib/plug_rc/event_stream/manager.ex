defmodule PlugRc.EventStream.Manager do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def connect(conn) do
    Supervisor.start_child(__MODULE__, [conn])
  end

  def init(:ok) do
    supervise([
      worker(EventStream, [], restart: :temporary)
    ], strategy: :simple_one_for_one)
  end
end
