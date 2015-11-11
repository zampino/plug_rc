module Remote (Model, init, Action, update, view) where

import Effects
import Task
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
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

type alias Message = { which: Int, action: String }
messageFor : Action -> Message
messageFor action =
  case log "messageFor action: " action of
    Left -> { which = 37, action = "turn" }
    Right -> { which = 38, action = "turn" }

requestTurn : String -> Message -> Effects.Effects Action
requestTurn id message =
  Http.post (Json.string) ("/connections/" ++ id) (Http.string (toString message))
  |> Task.toMaybe
  |> Task.map taskMap
  |> Effects.task

taskMap : Maybe String -> Action
taskMap r =
  case log "response" r of
    Just val -> NoOp
    Nothing -> NoOp

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ button [ onClick address Left ] [ text "<-" ]
    , div [ countStyle ] [ text model.connection_id ]
    , button [ onClick address Right ] [ text "->" ]
    ]

countStyle : Attribute
countStyle =
  style
    [ ("font-size", "20px")
    , ("font-family", "monospace")
    , ("display", "inline-block")
    , ("width", "50px")
    , ("text-align", "center")
    ]
