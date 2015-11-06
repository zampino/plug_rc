import RemoteList exposing (init, update, view, Action)
import StartApp exposing (start)

type ActionType = NoOp (String)
  | Join (String)
  | Leave (String)

type alias ConnectionInfo = { connection_id : String }

port handshakeEvents : Signal (List ConnectionInfo)
port connectionEvents : Signal (ActionType, ConnectionInfo)

connectionEventsSignal : Signal Action
connectionEventsSignal =
  Signal.map RemoteList.mapConnection connectionEvents


connectionEventsMap : (ActionType, ConnectionInfo) -> Action a
connectionEventsMap t, {connection_id} =
    case of t
      "join" -> Join connection_id
      "leave" -> Leave connection_id

handshakeEventsMap : List -> Action a
handshakeEventsMap list =
  Init list

handshakeEventsSignal : Signal Action
  Signal.map \x -> x handshakeEvents

app =
  start
    { init = init
    , update = update
    , view = view
    , inputs = [ handShakeEventsSignal, connectionEventsSignal]
    }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
