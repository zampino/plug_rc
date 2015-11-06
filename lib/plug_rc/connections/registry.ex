defmodule PlugRc.Connections.Registry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok,
      %{
        refs: HashDict.new,
        pids: HashDict.new,
        manager_pids: []
      }
    }
  end

  def handle_call({:register, conn}, _from, state) do
    {:ok, pid} = PlugRc.RemoteEventStream.connect conn
    id = make_id(conn)
    ref = Process.monitor pid
    pids = HashDict.put state.pids, id, pid
    refs = HashDict.put state.refs, ref, id
    notify_managers(state.manager_pids, "join", id)
    {:reply, {:ok, pid, id}, %{state | pids: pids, refs: refs}}
  end

  def handle_call({:register, :manager, conn}, _from, state) do
    {:ok, pid} = PlugRc.Connections.EventStream.connect(conn)
    {:reply, :ok, %{state | manager_pids: [pid | state.manager_pids]} }
  end

  def handle_call(:all, _from, state) do
    {:reply, HashDict.keys(state.pids), state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, HashDict.get(state.pids, id), state}
  end

  def handle_info({:DOWN, ref, :process, pid, :chunk_complete}, state) do
    {id, refs} = HashDict.pop state.refs, ref
    pids = HashDict.delete state.pids, id
    notify_managers state.manager_pids, "leave", id
    IO.puts "\n\n>>>>>>>>>> got it! >>>>>>>>>>>\n #{inspect(ref)}"
    {:noreply, %{state | refs: refs, pids: pids}}
  end

  def handle_info(whatever, state) do
    IO.puts "\n\n[INFO] received: \n#{inspect(whatever)}"
    {:noreply, state}
  end

  defp notify_managers([], _, _), do: :ok

  defp notify_managers([pid | tail], action, id) do
    GenEvent.ack_notify pid, %{action: action, body: %{connection_id: id}}
    notify_managers(tail, action, id)
  end

  defp make_id(_conn) do
    # TODO: better (short) a.u.ID
    inspect(:os.timestamp) |> Base.encode64()
  end
end
