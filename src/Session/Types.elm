
module Session.Types exposing (Session)

import User.Types exposing (User(..))
import Party.Types exposing (Party)
import Team.Types exposing (Team)

type alias Session =
    { user  : User
    , party : Maybe Party
    , team  : Maybe Team
    }

type alias SessionLookup =
    { userId  : Int
    , partyId : Maybe Int
    , teamId  : Maybe Int
    }
