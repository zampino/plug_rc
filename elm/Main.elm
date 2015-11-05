import RemoteList exposing (init, update, view)
import StartApp.Simple exposing (start)

type EventType = NoOp (String)
  | Join (String)
  | Leave (String)

type alias ConnectionEvent = { connection_id: String }
type alias HandShakeEvent = List (ConnectionEvent)

port handshakeEvents : Signal (HandShakeEvent)
port actionEvents : Signal (ActionType, ActionEvent)

-- connectionEventsSignal : Signal Manager.Operation
-- connectionEventsSignal =
--   Signal.map RemoteList.mapConnection connectionEvent

main =
  start
    { model = init
    , update = update
    , view = view
    }
