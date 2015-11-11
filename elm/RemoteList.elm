module RemoteList where

import Effects
import Remote
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

noFx x =
  (x, Effects.none)

type alias Model = List (Remote.Model)

init =
  noFx []

-- UPDATE
type alias ID = String
type Action
    =  NoOp
    | Init (List (Remote.Model))
    | Join Remote.Model
    | Leave Remote.Model
    | Control ID Remote.Action

join x = Join x
leave x = Leave x
initList list = Init list
noOp = NoOp

update : Action -> Model -> (Model, Effects.Effects e)
update action model =
  case action of
    NoOp ->
      noFx model
    Init list ->
      noFx ( List.map (\z -> Remote.init z) list )
    Join x ->
      noFx (x :: model)
    Leave x ->
      noFx ( List.filter (\y -> y.connection_id /= x.connection_id) model )
    Control c_id remote_action ->
      noFx model
      -- let
      --   reducer remote (list, e) =
      --     case remote.connection_id == c_id of
      --       true -> ( List.append( list [remote] ), snd ( Remote.update remote_action remote ))
      --       false -> ( List.append( list [remote] ), e )
      -- in
      --   List.foldl reducer init model

view : Signal.Address Action -> Model -> Html
view address model =
  div [] (List.map (viewRemote address) model)

viewRemote : Signal.Address Action -> Remote.Model -> Html
viewRemote address remote =
  Remote.view (Signal.forwardTo address (Control remote.connection_id)) remote
