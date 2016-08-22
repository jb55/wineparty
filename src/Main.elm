


--ours
import Party.Types exposing (Party)
import Party.View as Party
import Registration.View as Registration
import Session.Types exposing (Session, sessionDecoder)
import Team.Types exposing (Team)
import User.Types exposing (..)

import Dict exposing (Dict)
import Exts.RemoteData as RemoteData
import Exts.RemoteData exposing (RemoteData(..))
import Html exposing (..)
import Html.App as Html
import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode exposing ((:=))
import Platform.Cmd as Cmd
import Platform.Cmd exposing (Cmd(..))
import String exposing (split, trim, join)
import Task exposing (..)

type alias Cookies  = Dict String String
type alias Remote a = RemoteData String a

type alias Model = { session : Remote Session
                   , error   : Maybe String
                   , cookies : Dict String String
                   }

type Msg = FetchSessionId
         | NoSessionIdFound
         | SessionMsg (RemoteMsg Int String Session)

type RemoteMsg n e a = Ask n
                     | ReqFail e
                     | ReqSuccess a

main =
  Html.programWithFlags
    { init = init
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
                             Nothing    -> text "No parties"
                             Just party -> Party.view party

type alias Context = { cookies : String }

parseCookies : String -> Dict String String
parseCookies =
    let
        addCookieToDict =
            trim >> split "=" >> List.map Http.uriDecode >> addKeyValueToDict

        addKeyValueToDict keyValueList =
            case keyValueList of
                key :: value :: _ -> Dict.insert key value
                _ -> identity

    in
        List.foldl addCookieToDict Dict.empty << split ";"


init : Context -> (Model, Cmd Msg)
init ctx = update FetchSessionId 
             { session = NotAsked
             , error   = Nothing
             , cookies = parseCookies ctx.cookies
             }

newSession = Session Anonymous Nothing Nothing

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
      NoSessionIdFound ->
        ({ model | session = Success newSession }, Cmd.none)

      FetchSessionId ->
        let
            msessionId = Dict.get "session_id" model.cookies
                           `Maybe.andThen` (Result.toMaybe << String.toInt)
        in
            case msessionId of
              Nothing        -> update NoSessionIdFound model
              Just sessionId -> update (SessionMsg (Ask sessionId)) model

      (SessionMsg (Ask sessionId)) ->
         ({ model | session = Loading }, fetchSession sessionId)

      (SessionMsg (ReqSuccess session)) ->
         ({ model | session = Success session }, Cmd.none)

      (SessionMsg (ReqFail err)) ->
         ({ model | session = Failure err, error = Just err } , Cmd.none)


api : String -> String
api route = "http://pg-zero.wineparty.xyz" ++ route


fetchSession : Int -> Cmd Msg
fetchSession sessionId = 
  let
      decoder = Decode.map List.head (Decode.list ("get_session" := sessionDecoder))
                  `Decode.andThen` (\x -> case x of
                                            Nothing -> Decode.fail "get_session: empty list"
                                            Just x  -> Decode.succeed x)
      json    = Encode.object [("_session_id", Encode.int sessionId)]
      body    = Http.string (Encode.encode 0 json)
      req     = Http.send Http.defaultSettings
                 { verb    = "POST"
                 , headers = [("Content-Type", "application/json")]
                 , url     = api "/rpc/get_session"
                 , body    = body
                 }
  in
      Task.perform (SessionMsg << ReqFail << toString)
                   (SessionMsg << ReqSuccess)
                   (Http.fromJson decoder req)
