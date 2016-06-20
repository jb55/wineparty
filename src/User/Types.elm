
module User.Types exposing (User(..))

type alias UserData =
    { name : String
    , id   : Int
    }

type User = Anonymous
          | Registered UserData
