


--ours
import Main.Types exposing (..)
import Main.View exposing (mainView)
import Page.Registration exposing (..)
import Page exposing (..)
import Party.View as Party
import Page.Registration exposing (..)
import RemoteMsg exposing (..)
import Session.Types exposing (Session, sessionDecoder)
import User.Types exposing (..)

import Dict exposing (Dict)
import Exts.RemoteData as RemoteData
import Exts.RemoteData exposing (RemoteData(..))
import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode exposing ((:=))
import Json.Encode as Encode
import Navigation
import Platform.Cmd as Cmd
import Platform.Cmd exposing (Cmd(..))
import String exposing (split, trim, join)
import Task exposing (..)

type alias Cookies  = Dict String String
type alias Remote a = RemoteData String a

type alias Model = { session      : Remote Session
                   , sessionId    : Maybe Int
                   , page         : Page
                   , error        : Maybe String
                   , cookies      : Dict String String
                   }

main =
  Navigation.programWithFlags (Navigation.makeParser hashParser)
    { init = init
    , view = view
    , update = update
    , urlUpdate = urlUpdate
    , subscriptions = always Sub.none
    }

urlUpdate : Result String Page -> Model -> (Model, Cmd Msg)
urlUpdate res model =
  case Debug.log "urlUpdate" res of
    Err err -> (model, Navigation.modifyUrl (pageToHash model.page))
    Ok page ->
      let m = { model | page = page }
      in
        case model.session of
          NotAsked  -> update FetchSession m
          Failure _ -> update FetchSession m
          _         -> (m, Cmd.none)

view : Model -> Html Msg
view model =
    let
        body = case model.session of
                 NotAsked        -> [ text "User needs to be fetched..." ]
                 Loading         -> [ text "Loading..." ]
                 Success session -> [ initialView model.page session ]
                 Failure err     -> [ text ("Ooops, something went wrong: " ++ err) ]
        user = case model.session of
                 NotAsked  -> Anonymous
                 Loading   -> Anonymous
                 Success s -> s.user
                 Failure _ -> Anonymous
    in
        mainView user (div [] body)

initialView : Page -> Session -> Html Msg
initialView page session =
  case page of
    RegistrationPage reg -> Html.map (SwitchPage << RegistrationPage)
                                     (registrationView reg)
    TeamPage             -> text "Team"
    PartyPage            -> text "Party"

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


init : Context -> Result String Page -> (Model, Cmd Msg)
init ctx result =
  let
    model = { session   = NotAsked
            , error     = Nothing
            , sessionId = Nothing
            , page      = RegistrationPage ChooseReg
            , cookies   = parseCookies ctx.cookies
            }
  in
    urlUpdate result model
    



newSession : Session
newSession = Session Anonymous Nothing Nothing

refresh : Model -> (Model, Cmd Msg)
refresh model =
  case model.sessionId of
    Just sessionId -> update (SessionMsg (Ask sessionId)) model
    _              -> update FetchSession model


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case Debug.log "update" msg of
      NoSessionIdFound ->
        { model | session = Success newSession } ! [ Cmd.none ]

      FetchSession ->
        let
            -- TODO: local storage instead
            msessionId = Dict.get "session_id" model.cookies
                           `Maybe.andThen` (Result.toMaybe << String.toInt)
        in
            case msessionId of
              Nothing        -> update NoSessionIdFound model
              Just sessionId -> update (SessionMsg (Ask sessionId))
                                       { model | sessionId = Just sessionId }

      (SessionMsg (Ask sessionId)) ->
         { model | session = Loading } ! [ fetchSession sessionId ]

      (SessionMsg (ReqSuccess session)) ->
         { model | session = Success session } ! [ Cmd.none ]

      (SessionMsg (ReqFail err)) ->
         { model | session = Failure err, error = Just err } ! [ Cmd.none ]

      ClickParty -> refresh model
      ClickTeam  -> refresh model

      SwitchPage newPage ->
         model ! [ Navigation.newUrl (pageToHash newPage) ]


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
