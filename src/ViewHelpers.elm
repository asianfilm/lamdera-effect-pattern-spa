module ViewHelpers exposing (backgroundColorFromMode, textColorFromMode, viewButton)

import Html exposing (Html, button, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Session exposing (Mode(..), Session, getMode)


viewButton : Session -> String -> msg -> Html msg
viewButton session label msg =
    button
        [ style "color" (textColorFromMode (getMode session))
        , style "backgroundColor" (buttonBackgroundColorFromMode (getMode session))
        , style "padding" "0.5em"
        , style "border-radius" "0.4em"
        , style "margin-right" "0.4em"
        , style "outline" "none"
        , onClick msg
        ]
        [ text label ]


backgroundColorFromMode : Mode -> String
backgroundColorFromMode m =
    case m of
        DarkMode ->
            "#666666"

        LightMode ->
            "white"


buttonBackgroundColorFromMode : Mode -> String
buttonBackgroundColorFromMode m =
    case m of
        DarkMode ->
            "black"

        LightMode ->
            "white"


textColorFromMode : Mode -> String
textColorFromMode m =
    case m of
        DarkMode ->
            "#dddddd"

        LightMode ->
            "black"
