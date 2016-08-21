
module Party.View exposing (view)

import Html exposing (..)
import Party.Types exposing (Party)

view : Party -> Html msg
view party = div [] [ text "Party View" ]
