module View.Helpers exposing (..)

import Html exposing (Html, button, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Session exposing (Mode(..), Session, getMode)
import Time
import View.Link as Link


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


buttonId : String -> String
buttonId label =
    label |> String.replace " " "-" |> String.toLower |> String.append "button-"


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


viewButton : Session -> String -> msg -> Html msg
viewButton session label msg =
    button
        [ Attr.id (buttonId label)
        , Attr.style "color" (textColorFromMode (getMode session))
        , Attr.style "backgroundColor" (buttonBackgroundColorFromMode (getMode session))
        , Attr.style "padding" "0.5em"
        , Attr.style "border-radius" "0.4em"
        , Attr.style "margin-right" "0.4em"
        , Attr.style "outline" "none"
        , onClick msg
        ]
        [ text label ]


viewLink : Bool -> Bool -> String -> msg -> Html msg
viewLink active bounded label msg =
    Link.link
        |> Link.isActive active
        |> Link.isBounded bounded
        |> Link.onClick msg
        |> Link.withLabel label
        |> Link.view
