
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

type Msg = FetchUser Int
         | CookieMsg (RemoteMsg String Cookies)
         | FetchFail String
         | FetchSucceed Session

type RemoteMsg e a = Ask
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
        Registered user -> Party.view session.party


init : (Model, Cmd Msg)
init = update (CookieMsg Ask) { session = NotAsked, cookies = Loading }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
      (CookieMsg (ReqSuccess d)) ->
        let
            updatedModel = { model | cookies = Success d }
            msessionId = Dict.get "sessionId" d
                           `Maybe.andThen` (Result.toMaybe << String.toInt)
        in
            case msessionId of
              Nothing ->
                update (CookieMsg (ReqFail "session-id not found")) updatedModel
              Just sessionId -> update (FetchUser sessionId) updatedModel

      (CookieMsg Ask) ->
        (model, Task.perform (CookieMsg << ReqFail << toString)
                             (CookieMsg << ReqSuccess)
                             Cookies.get)

      FetchUser sessionId ->
          ({ model | session = Loading }, fetchSession sessionId)


api : String -> String
api route = "http://pg-zero.wineparty.xyz" ++ route

fetchSession : Int -> Cmd Msg
fetchSession sessionId =
    let getSession = Http.get sessionDecoder
                       (api ("/sessions?session_id=eq." ++ toString sessionId))
    in
        Task.perform (FetchFail << toString) FetchSucceed getSession
