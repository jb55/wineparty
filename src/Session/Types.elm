
module Session.Types exposing (Session, sessionDecoder)

import User.Types exposing (..)
import User.Types as User
import Party.Types exposing (Party, partyDecoder)
import Party.Types as Party
import Team.Types exposing (Team, teamDecoder)
import Team.Types as Team

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


type alias Session =
    { user  : User
    , party : Maybe Party
    , team  : Maybe Team
    }

type alias SessionLookup =
    { sessionId : Int
    , userId    : Int
    , partyId   : Maybe Int
    , teamId    : Maybe Int
    }

sessionDecoder : Decoder Session
sessionDecoder = decode Session
  |> required "user"  userDecoder
  |> required "party" (nullable partyDecoder)
  |> required "team"  (nullable teamDecoder)
