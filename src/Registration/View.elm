
module Registration.View exposing (view)

import Html exposing (..)
import String exposing (split)
import Maybe exposing (withDefault)

view : Html msg
view = div [] [ text "Registration view" ]

labelInput lbl =
  let
      short = withDefault "" List.head (split lbl)
      lower = toLower short
  in
      [ label [ for lbl ] [ text lbl ]
      , input [ class "form-control"
              , id lbl
              , placeholder short
              , type' lower
              ]
      ]

view : Html msg
view = 
  form []
      [ formGroup (labelInput "Email address")
      , formGroup
          [ label [ for "exampleInputPassword1" ] [ text "Password" ]
          , input [ class "form-control"
                  , id "exampleInputPassword1"
                  , placeholder "Password"
                  , type' "password"
                  ] []
          ]
      , formGroup
          [ label [ for "exampleInputFile" ] [ text "File input" ]
          , input [ id "exampleInputFile", type' "file" ] []
          , p [ class "help-block" ]
              [ text "Example block-level help text here." ]
          ]
      , div [ class "checkbox" ]
          [ label [] [ input [ type' "checkbox" ] []
                    , text "Check me out    "
                    ]
          ]
      , button [ class "btn btn-default", type' "submit" ]
          [ text "Submit" ]
      ]
