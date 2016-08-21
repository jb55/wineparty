
--ours
import Registration.View as Registration
import Session.Types exposing (Session, sessionDecoder)
import User.Types exposing (..)
import Party.View as Party

import Cookies
import Exts.RemoteData as RemoteData
import Exts.RemoteData exposing (RemoteData(..))
import Html exposing (..)
import Html.App as Html
import Http
import String
import Dict exposing (Dict)
import Platform.Cmd as Cmd
import Platform.Cmd exposing (Cmd(..))
import Task exposing (..)

type alias Cookies = Dict String String

type alias Model = { session : RemoteData String Session
                   , cookies : RemoteData String Cookies
                   }

type Msg = CookieMsg (RemoteMsg () String Cookies)
         | SessionMsg (RemoteMsg Int String Session)

type RemoteMsg n e a = Ask n
                     | ReqFail e
                     | ReqSuccess a

main : Program Never
main =
  Html.program { init = init
               , view = view
               , update = update
               , subscriptions = always Sub.none
               }

view : Model -> Html Msg
view model =
    let
        body = case model.session of
                 NotAsked        -> [ text "User needs to be fetched..." ]
                 Loading         -> [ ]
                 Success session -> [ initialView session ]
                 Failure err     -> [ text ("Ooops, something went wrong: " ++ err) ]
    in
        div [] body

initialView : Session -> Html Msg
initialView session =
    case session.user of
        Anonymous       -> Registration.view
        Registered user -> case session.party of
                             Nothing -> text "No party created"
                             Just p  -> Party.view p


init : (Model, Cmd Msg)
init = update (CookieMsg (Ask ())) { session = NotAsked, cookies = Loading }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
      (CookieMsg (ReqFail err)) ->
        ({ model | cookies = Failure err }, Cmd.none)

      (CookieMsg (ReqSuccess d)) ->
        let
            updatedModel = { model | cookies = Success d }
            msessionId = Dict.get "sessionId" d
                           `Maybe.andThen` (Result.toMaybe << String.toInt)
        in
            case msessionId of
              Nothing ->
                update (CookieMsg (ReqFail "session-id not found")) updatedModel
              Just sessionId -> update (SessionMsg (Ask sessionId)) updatedModel

      (CookieMsg (Ask ())) ->
        (model, Task.perform (CookieMsg << ReqFail << toString)
                             (CookieMsg << ReqSuccess)
                             Cookies.get)

      (SessionMsg (Ask sessionId)) ->
         ({ model | session = Loading }, fetchSession sessionId)

      (SessionMsg (ReqSuccess session)) ->
         ({ model | session = Success session }, Cmd.none)

      (SessionMsg (ReqFail err)) ->
         ({ model | session = Failure err }, Cmd.none)


api : String -> String
api route = "http://pg-zero.wineparty.xyz" ++ route

fetchSession : Int -> Cmd Msg
fetchSession sessionId =
    let getSession = Http.get sessionDecoder
                       (api ("/sessions?session_id=eq." ++ toString sessionId))
    in
        Task.perform (SessionMsg << ReqFail << toString)
                     (SessionMsg << ReqSuccess)
                     getSession
