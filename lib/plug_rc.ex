defmodule PlugRc do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    opts = [strategy: :one_for_one, name: PlugRc.Supervisor]
    [
      supervisor(PlugRc.Connections, []),
      supervisor(PlugRc.RemoteEventStream, []),
      worker(PlugRc.Server, [])
    ] |> Supervisor.start_link(opts)
  end
end
