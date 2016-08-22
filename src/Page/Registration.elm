
module Page.Registration exposing (Registration(..), registrationView)

import Maybe
import String exposing (split, toLower)
import Html exposing (..)
import Html as H
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type Registration = ChooseReg
                  | JoinTeam
                  | CreateTeam

labelInput lbl extra =
  let
      short = Maybe.withDefault "" (List.head (split " " lbl))
      lower = toLower short
  in
      [ label [ for lbl ] [ text lbl ]
      , input ([ class "form-control"
               , id lbl
               , placeholder short
               ] ++ extra) []
      ]

formGroup : List (Html msg) -> Html msg
formGroup = div [ class "form-group" ]

joinTeam : Html Registration
joinTeam =
  div []
    [ h3 [] [ text "Join Team" ]
    , H.form []
        [ formGroup (labelInput "Team Name" [ ])
        , button [ class "btn btn-default", type' "submit" ] [ text "Join" ]
        ]
    ]

createTeam : Html Registration
createTeam =
  div []
    [ h3 [] [ text "Create Team" ]
    , H.form []
        [ formGroup (labelInput "Team Name" [ ])
        , button [ class "btn btn-default", type' "submit" ] [ text "Create" ]
        ]
    ]

choose : Html Registration
choose =
  div []
    [ h3 [] [ text "Team" ]
    , button [ class "btn btn-primary btn-lg btn-block"
             , type' "button"
             , onClick CreateTeam
             ]
             [ text "Create Team" ]
    , button [ class "btn btn-default btn-lg btn-block"
             , type' "button"
             , onClick JoinTeam
             ]
             [ text "Join Team" ]
    ]


registrationView : Registration -> Html Registration
registrationView reg =
  case reg of
    ChooseReg  -> choose
    JoinTeam   -> joinTeam
    CreateTeam -> createTeam
