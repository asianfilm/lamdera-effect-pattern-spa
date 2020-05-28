module ViewHelpers exposing (..)

import Html exposing (Attribute, Html, a, button, div, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Session exposing (Mode(..), Session, getMode)
import Time


navLink : Bool -> Bool -> String -> Attribute msg -> Html msg
navLink isActive isBounded label href =
    a
        [ Attr.id (labelToId "link" label)
        , Attr.class "block mt-4 lg:inline-block lg:mt-0 text-teal-200 mr-4"
        , Attr.classList [ ( "inline-block text-sm px-4 py-2 leading-none border rounded text-white border-white hover:border-transparent hover:text-teal-500 hover:bg-white", isBounded ) ]
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


viewFooter : Html msg
viewFooter =
    div [ Attr.style "position" "absolute", Attr.style "margin-left" "2em", Attr.style "width" "100%", Attr.style "bottom" "0", Attr.style "height" "2em" ]
        [ text "Based on "
        , a [ Attr.id "link-inspiration", Attr.href "https://github.com/dmy/elm-realworld-example-app" ]
            [ text "Elm RealWorld Example" ]
        ]


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
