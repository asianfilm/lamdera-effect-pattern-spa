module ViewHelpers exposing (..)

import Html exposing (Attribute, Html, a, button, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Session exposing (Mode(..), Session, getMode)
import Time


navLink : Bool -> Bool -> String -> Attribute msg -> Html msg
navLink isActive isLogo label href =
    a
        [ Attr.id (labelToId "link" label)
        , Attr.class "block inline-block mt-0 text-teal-200 mr-4"
        , Attr.classList [ ( "flex items-center flex-shrink-0 text-white mr-6 font-semibold text-xl tracking-tight", isLogo ) ]
        , Attr.classList [ ( "hover:text-white", not isActive ) ]
        , href
        ]
        [ text label ]


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
        [ Attr.id (labelToId "button" label)
        , Attr.style "color" (textColorFromMode (getMode session))
        , Attr.style "backgroundColor" (buttonBackgroundColorFromMode (getMode session))
        , Attr.style "padding" "0.5em"
        , Attr.style "border-radius" "0.4em"
        , Attr.style "margin-right" "0.4em"
        , Attr.style "outline" "none"
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
