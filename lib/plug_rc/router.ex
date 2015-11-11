defmodule PlugRc.Router do
  use Plug.Router

  plug Plug.Parsers, parsers: [:json], pass: "text/*", json_decoder: Poison

  plug PlugCors, [
    origins: ["localhost:3000", "localhost:3001", "http://zampino.github.io"],
    headers: ["accept", "origin", "content-type"]
  ]

  plug Plug.Static, at: "/", from: "static"

  plug :match
  plug :dispatch

  def init(_options), do: []

  get "/connections" do
    conn = put_resp_content_type(conn, "text/event-stream")
    |> send_chunked(200)
    |> register_controller()
    handshake = Poison.encode_to_iodata! PlugRc.Connections.remotes
    assign(conn, :init_chunk, "retry: 6000\nevent: handshake\ndata: #{handshake}\n\n")
  end

  get "/remote" do
    {conn, id} = put_resp_content_type(conn, "text/event-stream")
    |> send_chunked(200)
    |> register_remote()
    handshake = Poison.encode_to_iodata!(%{connection_id: id})
    assign(conn, :init_chunk, "retry: 6000\nevent: handshake\ndata: #{handshake}\n\n")
  end

  post "/connections/:id" do
    %Plug.Conn{params: params} = conn
    event = %{type: params["type"], which: params["which"]}
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
    {:ok, _pid, _id} = PlugRc.Connections.register_controller conn
    conn
  end

  defp register_remote(conn) do
    {:ok, pid, id} = PlugRc.Connections.register_remote conn
    Process.link pid
    {conn, id}
  end
end
