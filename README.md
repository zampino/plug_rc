# PlugRc

A Remote Controller for my [slides](http://zampino.github.io/talks)

It just streams _left_ and _right_ events over `EventSource` connections.
Whenever a slides engine connects, a remote control session appears
on the manager with a pair of buttons. You can connect potentially
infinite slides and infinite controllers, but why?.

It uses [Pastelli](https://github.com/zampino/pastelli) Plug adapter to serve a
simple Elixir Plug router with a mini Elm layer.

It's live [here](http://plugrc.herokuapp.com/index.html).


## Event Streams

Elixir GenEvent streams abstract incredibly well
server-sent event sourcing, like in this very twenty lines of code:

```elixir
defmodule EventStream do

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
    Plug.Conn.chunk conn, "event: message\ndata: #{json_data}\n\n"
  end
end
```
once your state boots `EventStream` and captures `events_pid`, then
it's just a matter of
```elixir
GenEvent.ack_notify events_pid, %{hallo: "world"}
```
