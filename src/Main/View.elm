
module Main.View exposing (mainView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Main.Types exposing (..)
import User.Types exposing (..)
import Page exposing (..)

nav : User -> Html Msg
nav user = Html.nav [ class "navbar navbar-default navbar-static-top" ]
    [ div [ class "container" ]
        [ div [ class "navbar-header" ]
            [ button [ attribute "aria-controls" "navbar"
                     , attribute "aria-expanded" "false"
                     , class "navbar-toggle collapsed"
                     , attribute "data-target" "#navbar"
                     , attribute "data-toggle" "collapse"
                     , type' "button" ]
                [ span [ class "sr-only" ] [ text "Toggle navigation" ]
                , span [ class "icon-bar" ] []
                , span [ class "icon-bar" ] []
                , span [ class "icon-bar" ] []
                ]
            , a [ class "navbar-brand", href "#" ]
                [ text "Wine Party" ]
            ]
        , div [ class "navbar-collapse collapse", id "navbar" ]
            [ ul [ class "nav navbar-nav" ]
                [ li [ class "active" ]     [ a [ href "#" ] [ text "Home" ] ]
                , li [] [ a [ onClick (SwitchPage TeamPage), href "javascript:false;" ] [ text "Team" ] ]
                , li [] [ a [ onClick (SwitchPage PartyPage), href "javascript:false;" ] [ text "Party" ] ]
                , li [ class "dropdown" ]
                    [ a [ attribute "aria-expanded" "false"
                        , attribute "aria-haspopup" "true"
                        , class "dropdown-toggle"
                        , attribute "data-toggle" "dropdown"
                        , href "#"
                        , attribute "role" "button"
                        ]
                        [ text "Dropdown "
                        , span [ class "caret" ] []
                        ]
                    , ul [ class "dropdown-menu" ]
                        [ li [] [ a [ href "#" ] [ text "Action" ] ]
                        , li [] [ a [ href "#" ] [ text "Another action" ] ]
                        , li [] [ a [ href "#" ] [ text "Something else here" ] ]
                        , li [ class "divider", attribute "role" "separator" ] []
                        , li [ class "dropdown-header" ] [ text "Nav header" ]
                        , li [] [ a [ href "#" ] [ text "Separated link" ] ]
                        , li [] [ a [ href "#" ] [ text "One more separated link" ] ]
                        ]
                    ]
                ]
            , ul [ class "nav navbar-nav navbar-right" ]
                 [ li [] [ a [ href "#" ] [ text (userName user) ] ] ]
            ]
        , text "      "
        ]
    ]

userName : User -> String
userName user =
  case user of
    Anonymous       -> "Anonymous"
    Registered user -> user.name

mainView : User -> Html Msg -> Html Msg
mainView user c =
  div []
      [ nav user
      , div [ class "container" ] [ c ] 
      ]
