defmodule PlugRc.Router do
  use Plug.Router

  plug Plug.Parsers, parsers: [:json], pass: "text/*", json_decoder: Poison

  plug PlugCors, [
    origins: ["localhost:3000", "localhost:3001", "https://zampino.github.io"],
  ]

  plug :match

  plug :dispatch

  def init(_options), do: []

  get "/" do
    send_resp(conn, 200, "<h1>Active Connections</h1><ul>"
      <> Enum.map_join(PlugRc.Connections.all, &("<li>#{&1}</li>"))
      <> "</ul>")
  end

  get "/connections/:id" do
    put_resp_content_type(conn, "text/event-stream")
    |> assign(:init_chunk,
      "retry: 6000\nevent: handshake\ndata: connected #{id}\n\n")
    |> send_chunked(200)
    |> register_stream(id)
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
    halt(conn)
  end

  ## private

  defp register_stream(conn, id) do
    {:ok, pid} = PlugRc.Connections.register id, conn
    Process.link pid
    conn
  end
end
