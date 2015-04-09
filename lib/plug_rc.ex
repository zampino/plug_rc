defmodule PlugRc do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    opts = [strategy: :one_for_one, name: PlugRc.Supervisor]

    [
      supervisor(PlugRc.Connections.Supervisor, []),
      worker(PlugRc.Server, [])
    ] |> Supervisor.start_link(opts)
  end
end
