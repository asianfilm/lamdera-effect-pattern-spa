module ViewHelpers exposing (backgroundColorFromMode, labelToId, textColorFromMode, viewButton)

import Html exposing (Html, button, text)
import Html.Attributes exposing (id, style)
import Html.Events exposing (onClick)
import Session exposing (Mode(..), Session, getMode)


labelToId : String -> String -> String
labelToId kind label =
    label
        |> String.replace " " "-"
        |> String.toLower
        |> String.append "-"
        |> String.append kind


viewButton : Session -> String -> msg -> Html msg
viewButton session label msg =
    button
        [ id (labelToId "button" label)
        , style "color" (textColorFromMode (getMode session))
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
