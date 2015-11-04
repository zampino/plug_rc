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

  # get "/" do
  #   send_resp(conn, 200, "<h1>Active Connections</h1><ul>"
  #     <> Enum.map_join(PlugRc.Connections.all, &("<li>#{&1}</li>"))
  #     <> "</ul>")
  # end

  get "/connections" do
    conn = put_resp_content_type(conn, "text/event-stream") |> register_manager()
    handshake = Poison.encode_to_iodata! PlugRc.Connections.all
    assign(conn, :init_chunk, "retry: 6000\nevent: handshake\ndata: #{handshake}\n\n")
    |> send_chunked(200)
  end

  get "/remote" do
    {conn, id} = put_resp_content_type(conn, "text/event-stream")
    |> register_stream()
    handshake = Poison.encode_to_iodata!(%{connection_id: id})
    assign(conn, :init_chunk, "retry: 6000\nevent: handshake\ndata: #{handshake}\n\n")
    |> send_chunked(200)
  end

  post "/connections/:id" do
    %Plug.Conn{params: params} = conn
    event = %{type: params["type"], which: params["which"]}
    :ok = PlugRc.Connections.notify id, event
    send_resp(conn, 201, '')
  end

  options "/connections/:id" do
    IO.puts ">>> preflight! <<<<<\n"
    send_resp(conn, 204, "")
  end

  match _ do
    IO.puts "||||| MISS!!! ||||"
    halt(conn)
  end

  defp register_manager(conn) do
    :ok = PlugRc.Connections.register_manager conn
    conn
  end

  defp register_stream(conn) do
    {:ok, pid, id} = PlugRc.Connections.register conn
    Process.link pid
    {conn, id}
  end
end
