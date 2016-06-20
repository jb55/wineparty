
import Cookies
import Exts.RemoteData as RemoteData
import Exts.RemoteData exposing (RemoteData(..))
import Html exposing (..)
import Html.App as Html
import Platform.Cmd as Cmd
import Platform.Cmd exposing (Cmd(..))
import Registration.View as Registration
import Session.Types exposing (Session)

type alias Model = { session : RemoteData String Session }

type Msg = FetchUser
         | FetchFail String
         | FetchSucceed Session


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
        body = case model.user of
                  NotAsked     -> [ text "User needs to be fetched..." ]
                  Loading      -> [ ]
                  Success user -> [ initialView user ]
                  Failure err  -> [ text ("Ooops, something went wrong: " ++ err) ]
    in
        div [] body

initialView : User -> Html Msg
initialView user =
    case user of
        Anonymous       -> Registration.view
        Registered user -> Party.view


init : (Model, Cmd Msg)
init = update FetchUser { user = NotAsked }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FetchUser -> ({ model | user = Loading }, fetchSession)


fetchSession : Cmd k
fetchSession session =
    let cookie = Cookies.getString "session-id"
    in
        Task.perform FetchFail FetchSucceed
