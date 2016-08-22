
module RemoteMsg exposing (RemoteMsg(..))

type RemoteMsg n e a = Ask n
                     | ReqFail e
                     | ReqSuccess a
