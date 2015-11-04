defmodule EventStream do
  def start_link(conn, options \\ []) do
    {:ok, events_pid} = GenEvent.start_link options
    IO.puts "-->> starting EventStream with #{inspect options}"
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
    IO.puts "SENDING: #{inspect json_data}"
    Plug.Conn.chunk conn, "data: #{json_data}\n\n"
    # NEXT: Pastelli.Conn.event conn, event
  end
end
