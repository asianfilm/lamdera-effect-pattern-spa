module View.Button exposing (button, onClick, view, withLabel, withMode)

import Html exposing (Html, div, text)
import Html.Attributes as Attr
import Html.Events as Events
import Session exposing (Mode(..))


type Button msg
    = Button
        { color : String
        , label : String
        , onClick : msg
        }


button : Button ()
button =
    Button
        { color = "white"
        , label = ""
        , onClick = ()
        }


buttonId : String -> String
buttonId label =
    label |> String.replace " " "-" |> String.toLower |> String.append "button-"


colorFromMode : Mode -> String
colorFromMode m =
    case m of
        DarkMode ->
            "black"

        LightMode ->
            "white"


onClick : msgB -> Button msgA -> Button msgB
onClick onClick_ (Button config) =
    Button
        { color = config.color
        , label = config.label
        , onClick = onClick_
        }


withMode : Mode -> Button msg -> Button msg
withMode m (Button config) =
    Button { config | color = colorFromMode m }


withLabel : String -> Button msg -> Button msg
withLabel label (Button config) =
    Button { config | label = label }


view : Button msg -> Html msg
view (Button config) =
    div [ Attr.style "display" "inline" ]
        [ Html.button
            [ Attr.id (buttonId config.label)
            , Attr.style "backgroundColor" config.color
            , Attr.style "padding" "0.5em"
            , Attr.style "border-radius" "0.4em"
            , Attr.style "margin-right" "0.4em"
            , Attr.style "outline" "none"
            , Events.onClick config.onClick
            ]
            [ text config.label ]
        ]
