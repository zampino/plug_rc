module Remote (Model, init, Action, update, view) where

import Effects
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model = {id : String}
type Action = Left | Right

init {connection_id} =
  Model connection_id

update : Action -> Model -> (Model, Effects.Effects e)
update action model =
  case action of
    Left -> (model, Effects.none)
    Right -> (model, Effects.none)

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ button [ onClick address Left ] [ text "<-" ]
    , div [ countStyle ] [ text (toString model) ]
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
