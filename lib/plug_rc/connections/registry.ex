defmodule PlugRc.Connections.Registry do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok,
      %{
        refs: HashDict.new,
        pids: %{
          remote: HashDict.new,
          controller: HashDict.new
        }
      }
    }
  end

  def handle_call({:register, type, conn}, _from, state) do
    {:ok, pid} = PlugRc.EventStream.Manager.connect conn
    id = make_id()
    ref = Process.monitor pid
    new_pids_hash = HashDict.put state.pids[type], id, pid
    new_pids = Map.put state.pids, type, new_pids_hash
    new_refs = HashDict.put state.refs, ref, {type, id}
    if (type == :remote), do: notify_controllers(state, "join", id)
    {:reply, {:ok, pid, id}, %{state | pids: new_pids, refs: new_refs}}
  end

  def handle_call(:remotes, _from, state) do
    reply = HashDict.keys(state.pids[:remote])
    |> Enum.map &(%{ connection_id: &1 })
    {:reply, reply, state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, HashDict.get(state.pids[:remote], id), state}
  end

  def handle_info({:DOWN, ref, :process, _pid, :chunk_complete}, state) do
    {{type, id}, new_refs} = HashDict.pop state.refs, ref
    {pid, new_pids_hash} = HashDict.pop state.pids[type], id
    # TODO:
    Logger.info "CONNECTION CLOSED: #{id} #{type}"
    ^_pid = pid
    new_pids = Map.put state.pids, type, new_pids_hash
    if (type == :remote), do: notify_controllers(state, "leave", id)
    {:noreply, %{state | refs: new_refs, pids: new_pids}}
  end

  def handle_info(whatever, state) do
    IO.puts "\n\n[INFO] received: \n#{inspect(whatever)}"
    {:noreply, state}
  end

  defp notify_controllers(state, action, id) do
    pids = state.pids.controller |> HashDict.values()
    Logger.debug "\n ||| notify_controllers ||| #{inspect pids} ||| #{action} ||| #{id}"
    notify_controller_pids pids, action, id
  end

  defp notify_controller_pids([], _, _), do: :ok

  defp notify_controller_pids([pid | rest], action, id) do
    GenEvent.ack_notify pid, %{action: action, body: %{connection_id: id}}
    notify_controller_pids(rest, action, id)
  end

  defp make_id do
    h = Hashids.new min_len: 4
    Hashids.encode h, :erlang.unique_integer([:positive])
  end
end
