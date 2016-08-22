
module User.Types exposing
    ( User(..)
    , UserData
    , userDecoder
    )

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)

type alias UserData =
    { name : String
    , id   : Int
    }

type User = Anonymous
          | Registered UserData

userDecoder : Decoder UserData
userDecoder = decode UserData
                |> required "name" string
                |> required "user_id" int
