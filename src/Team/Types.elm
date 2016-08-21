
module Team.Types exposing (Team, teamDecoder)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)

type alias Team = { name : String }

teamDecoder : Decoder Team
teamDecoder = decode Team |> required "name" string
