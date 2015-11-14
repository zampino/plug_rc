defmodule PlugRc.Router do
  require Logger
  use Pastelli.Router

  plug Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Poison

  plug PlugCors, [
    origins: ["localhost:3000", "localhost:3001", "http://zampino.github.io"],
    headers: ["accept", "origin", "content-type"]
  ]

  plug Plug.Static, at: "/", from: "static"

  plug :match
  plug :dispatch

  def init(_options), do: []

  stream "/connections" do
    register_controller(conn)
    |> init_chunk(PlugRc.Connections.remotes, event: :handshake)
  end

  stream "/remote" do
    {conn, id} = register_remote(conn)
    init_chunk conn, %{connection_id: id}, event: :handshake
  end

  post "/connections/:id" do
    %Plug.Conn{params: params} = conn
    Logger.debug "[POST] /connections/#{id} { #{inspect params} }"
    event = %{action: params["action"], which: params["which"]}
    :ok = PlugRc.Connections.notify id, event
    send_resp(conn, 201, '')
  end

  options "/remote" do
    IO.puts ">>> preflight! <<<<<\n"
    send_resp(conn, 204, "")
  end

  match _ do
    IO.puts "||||| MISS!!! ||||"
    halt(conn)
  end

  defp register_controller(conn) do
    {:ok, pid, _id} = PlugRc.Connections.register_controller conn
    Process.link pid
    conn
  end

  defp register_remote(conn) do
    {:ok, pid, id} = PlugRc.Connections.register_remote conn
    Process.link pid
    {conn, id}
  end
end
