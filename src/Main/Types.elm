
module Main.Types exposing (Msg(..))

import RemoteMsg exposing (RemoteMsg(..))
import Session.Types exposing (Session)
import Page exposing (Page(..))

type Msg = FetchSession
         | NoSessionIdFound
         | SwitchPage Page
         | SessionMsg (RemoteMsg Int String Session)
