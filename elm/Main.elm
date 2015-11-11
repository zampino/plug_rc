import RemoteList
import Remote
import StartApp exposing (start)
import Task
import Effects
import Debug exposing (log)

port handshakeEvents : Signal (List (Remote.Model))
port connectionEvents : Signal (String, Remote.Model)

connectionEventsMap : (String, Remote.Model) -> RemoteList.Action
connectionEventsMap (t, conn) =
    case log "event type" t of
      "join" ->
        RemoteList.join conn
      "leave" ->
        RemoteList.leave conn
      "noOp" ->
        RemoteList.noOp

connectionEventsSignal : Signal RemoteList.Action
connectionEventsSignal =
  Signal.map connectionEventsMap connectionEvents

handshakeEventsMap : (List (Remote.Model)) -> RemoteList.Action
handshakeEventsMap list =
  RemoteList.initList list
handshakeEventsSignal : Signal RemoteList.Action
handshakeEventsSignal =
  Signal.map handshakeEventsMap handshakeEvents

app =
  start
    { init = RemoteList.init
    , update = RemoteList.update
    , view = RemoteList.view
    , inputs = [ handshakeEventsSignal, connectionEventsSignal ]
    }
main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
