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
    Logger.info "\nSENDING: #{inspect event}\n"
    Pastelli.Conn.event conn, event
  end
end
