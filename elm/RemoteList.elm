module RemoteList where

import Effects
import Remote
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model = List (Remote.Model)

noFx x =
  (x, Effects.none)

init : (Model, Effects.Effects e)
init = ([], Effects.none)

-- UPDATE
type alias ID = String
type Action
    =  NoOp
    | Init (List (ConnectionInfo))
    | Join (ConnectionInfo)
    | Leave (ConnectionInfo)
--  | Control ID Remote.Action

update : Action -> Model -> (Model, Effects.Effects e)
update action model =
  case action of
    NoOp ->
      noFx model
    Join info ->
      noFx ((Remote.init info) :: model)

    Leave info ->
      noFx ( List.filter ( \x -> x.id /= info.connection_id ) model )

    Init list ->
      noFx ( List.map (\info -> Remote.init info) list )
    -- Modify id RemoteAction ->
    --   let updateRemote (RemoteID, RemoteModel) =
    --         if RemoteID == id
    --             then (RemoteID, Remote.update RemoteAction RemoteModel)
    --             else (RemoteID, RemoteModel)
    --   in
    --       { model | remote <- List.map updateRemote model.remote }

view : Signal.Address Action -> Model -> Html
view address model =
  div [] List.map (viewRemote address) model

viewRemote : Signal.Address Action -> Remote.Model -> Html
viewRemote address remote =
  Remote.view (Signal.forwardTo address ()) remote
  -- Remote.view (Signal.forwardTo address (Control remote.id)) remote
