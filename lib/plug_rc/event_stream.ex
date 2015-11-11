defmodule EventStream do
  require Logger
  
  def start_link(conn) do
    {:ok, events_pid} = GenEvent.start_link
    Task.start_link __MODULE__, :stream, [conn, events_pid]
    {:ok, events_pid}
  end

  def stream(conn, events_pid) do
    GenEvent.stream(events_pid)
    |> Stream.each(&send_event(&1, conn))
    |> Stream.run
  end

  def send_event(event, conn) do
    json_data = Poison.encode_to_iodata!(event)
    Logger.info "\nSENDING: #{inspect event}\n"
    Plug.Conn.chunk conn, "event: message\ndata: #{json_data}\n\n"
  end
end
