defmodule PlugRc.Connections.EventHandler do

  def init(conn) do
    {:ok, conn}
  end

  def handle_event(event, conn) do
    encoded = Poison.encode_to_iodata!(event)
    Plug.Conn.chunk(conn, "data: #{encoded}\n\n")
    {:ok, conn}
  end
end
