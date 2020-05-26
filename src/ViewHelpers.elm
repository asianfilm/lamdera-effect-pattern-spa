module ViewHelpers exposing (backgroundColorFromMode, formatTime, labelToId, textColorFromMode, viewButton)

import Html exposing (Html, button, text)
import Html.Attributes exposing (id, style)
import Html.Events exposing (onClick)
import Session exposing (Mode(..), Session, getMode)
import Time


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


formatTime : Time.Zone -> Time.Posix -> String
formatTime zone posix =
    let
        element : (Time.Zone -> Time.Posix -> Int) -> String
        element e =
            String.padLeft 2 '0' <| String.fromInt <| e zone posix
    in
    element Time.toHour ++ ":" ++ element Time.toMinute


textColorFromMode : Mode -> String
textColorFromMode m =
    case m of
        DarkMode ->
            "#dddddd"

        LightMode ->
            "black"
