
module Page exposing (Page(..), pageToHash, pageParser, hashParser)

import UrlParser exposing (..)
import String
import Page.Registration exposing (Registration(..))

type Page = RegistrationPage Registration
          | TeamPage
          | PartyPage
          | HomePage

pageToHash : Page -> String
pageToHash page =
  case page of
    RegistrationPage reg ->
      case reg of
        ChooseReg  -> "#register"
        JoinTeam   -> "#register/join"
        CreateTeam -> "#register/create"

    TeamPage ->
      "#team"

    PartyPage ->
      "#party"

    HomePage ->
      "#"

hashParser loc =
  UrlParser.parse identity pageParser (String.dropLeft 1 loc.hash)

pageParser : Parser (Page -> a) a
pageParser =
  oneOf
    [ format (RegistrationPage JoinTeam)   (s "register" </> s "join")
    , format (RegistrationPage CreateTeam) (s "register" </> s "create")
    , format (RegistrationPage ChooseReg)  (s "register")
    , format TeamPage  (s "team")
    , format PartyPage (s "party")
    , format HomePage  (s "")
    ]
