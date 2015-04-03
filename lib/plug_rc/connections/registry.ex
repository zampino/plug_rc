defmodule PlugRc.Connections.Registry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok,
      %{
        refs: HashDict.new,
        pids: HashDict.new
      }
    }
  end

  def handle_call({:register, id}, _from, state) do
    {:ok, pid} = PlugRc.Connections.EventManagers.add id
    ref = Process.monitor pid
    pids = HashDict.put state.pids, id, pid
    refs = HashDict.put state.refs, ref, id
    {:reply, pid, %{state | pids: pids, refs: refs}}
  end

  def handle_call(:all, _from, state) do
    {:reply, HashDict.keys(state.pids), state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, HashDict.get(state.pids, id), state}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    {id, refs} = HashDict.pop state.refs, ref
    pids = HashDict.delete state.pids, id
    IO.puts ">>>>>>>>>> got it! #{inspect(ref)}"
    {:noreply, %{state | refs: refs, pids: pids}}
  end

  def handle_info(whatever, state) do
    IO.puts "received: #{inspect(whatever)}"
    {:noreply, state}
  end
end
