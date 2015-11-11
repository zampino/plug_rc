module Remote (Model, init, Action, update, view) where

import Effects
import Task
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JSDecode
import Json.Encode as JSEncode
import Debug exposing (log)

type alias Model = { connection_id : String }
type Action = NoOp | Left | Right

init : { x | connection_id : String } -> Model
init x =
  Model x.connection_id

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)
    _ -> (model, requestTurn model.connection_id (messageFor action))

messageFor : Action -> JSEncode.Value
messageFor action =
  case log "messageFor action: " action of
    Left  -> JSEncode.object [("which", JSEncode.int 37), ("action", JSEncode.string "turn")]
    Right  -> JSEncode.object [("which", JSEncode.int 39), ("action", JSEncode.string "turn")]

requestTurn : String -> JSEncode.Value -> Effects.Effects Action
requestTurn id message =
  postJson  ("/connections/" ++ id) message
  |> Task.toMaybe
  |> Task.map ( always NoOp )
  |> Effects.task

postJson url body =
  let request =
    { verb = "POST"
    , headers = [("content-type", "application/json")]
    , url = url
    , body = Http.string ( JSEncode.encode 0 body )
    }
  in
    Http.fromJson (JSDecode.string) (Http.send Http.defaultSettings request)

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ button [ (onClick address Left), buttonStyle ] [ text "<" ]
    , div [ textStyle ] [ text model.connection_id ]
    , button [ (onClick address Right), buttonStyle ] [ text ">" ]
    ]

buttonStyle =
  style
    [ ("font-size", "3em")
    , ("margin", "0 1em")
    ]

textStyle =
  style
    [ ("font-size", "10em")
    , ("font-family", "monospace")
    , ("display", "inline-block")
--    , ("width", "50px")
    , ("text-align", "center")
    , ("margin-bottom", "1em")
    ]
