
module Party.Types exposing (Party, partyDecoder)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)

type alias Party = { name : String }

partyDecoder : Decoder Party
partyDecoder = decode Party
                 |> required "name" string
