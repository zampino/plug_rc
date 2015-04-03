defmodule PlugRc.Router do
  use Plug.Router

  defmodule Event, do: (defstruct type: nil, which: nil)

  plug PlugCors, [
    origins: ["localhost:3000", "localhost:3001", "https://zampino.github.io"]
  ]

  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], pass: "text/*"

  plug :match
  plug :dispatch

  def init(_options\\[]) do
    []
  end

  get "/" do
    send_resp(conn, 200, "ahoi")
  end

  get "/connections/:id" do
    conn = put_resp_content_type(conn, "text/event-stream")
    |> fetch_params()
    |> send_chunked(200)

    false = Process.flag(:trap_exit, true)
    num = Process.flag(conn.owner, :save_calls, 100)
    Process.link(conn.owner)
    spawn_link __MODULE__, :info_recorder, [conn.owner, self]

    IO.puts "saved_calls: #{num}\nid: #{id}\np: #{inspect(conn.params)}\nh: #{inspect(conn.req_headers)}"

    chunk(conn, "retry: 6000\nid: #{id}\nevent: handshake\ndata: connected #{id}\n\n")
    # |> stream(pid)

    stream
  end

  def stream do
    receive do
      %Event{} = e ->
        react_on(e)
      x ->
        IO.puts "received unknown: #{inspect(x)}"
        stream
    end
  end

  options "/connections/:id" do
    IO.puts "preflight!\n#{inspect(conn)}"
    halt(conn)
  end

  def react_on(e) do
    IO.puts "received: #{inspect(e)}"
  end


  def info_recorder(owner_pid, conn_pid) do
    :timer.sleep 5000
    IO.puts "[INFO//owner]: #{inspect(Process.info(owner_pid))}\n\n[INFO//conn]: #{inspect(Process.info(conn_pid))}\n\n\n"
    info_recorder(owner_pid, conn_pid)
  end
  # defp stream(conn, pid) do
  #   GenEvent.stream(pid, timeout: 1800000)
  #   |> Stream.each(&send_event(&1, conn))
  #   |> Stream.run
  # end
  #
  # defp send_event(event, conn) do
  #   json_data = Poison.encode_to_iodata!(event)
  #   {status, conn_or_reason} = chunk(conn, "data: #{json_data}\n\n")
  #   if status == :error do
  #     IO.puts("|||||||||||||||||||||||||#{status}: #{conn_or_reason}, exiting...")
  #     :timer.sleep 1000
  #     Process.exit self, :kill
  #   end
  # end
end
