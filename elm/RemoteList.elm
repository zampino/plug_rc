module RemoteList where

import Remote
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL

type alias Model = List ( ID, Remote.Model )
type alias ID = String

init : Model
init = []

-- UPDATE

type Action
    = Join ID
    | Leave ID
    | Control ID Remote.Action

update : Action -> Model -> Model
update action model =
  case action of
    Insert ->
      { model |
          remote <- ( model.nextID, Remote.init 0 ) :: model.remote,
          nextID <- model.nextID + 1
      }

    Remove id ->
      { model |
          remote <- List.filter (\(RemoteID, _) -> RemoteID /= id) model.remote
      }

    Modify id RemoteAction ->
      let updateRemote (RemoteID, RemoteModel) =
            if RemoteID == id
                then (RemoteID, Remote.update RemoteAction RemoteModel)
                else (RemoteID, RemoteModel)
      in
          { model | remote <- List.map updateRemote model.remote }


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  let insert = button [ onClick address Insert ] [ text "Add" ]
  in
      div [] (insert :: List.map (viewRemote address) model.remote)


viewRemote : Signal.Address Action -> (ID, Remote.Model) -> Html
viewRemote address (id, model) =
  let context =
        Remote.Context
          (Signal.forwardTo address (Modify id))
          (Signal.forwardTo address (always (Remove id)))
  in
      Remote.viewWithRemoveButton context model
