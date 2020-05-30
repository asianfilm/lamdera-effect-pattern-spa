module View.Button exposing (button, onClick, view, withLabel, withMode)

import Html exposing (Html, div, text)
import Html.Attributes as Attr
import Html.Events as Events
import Session exposing (Mode(..))


type Button msg
    = Button
        { background : String
        , color : String
        , label : String
        , onClick : msg
        }



-- BUILDERS


button : Button ()
button =
    Button
        { background = ""
        , color = ""
        , label = ""
        , onClick = ()
        }


onClick : msgB -> Button msgA -> Button msgB
onClick onClick_ (Button config) =
    Button
        { background = config.background
        , color = config.color
        , label = config.label
        , onClick = onClick_
        }


withMode : Mode -> Button msg -> Button msg
withMode m (Button config) =
    Button
        { config
            | background = backgroundColorFromMode m
            , color = colorFromMode m
        }


withLabel : String -> Button msg -> Button msg
withLabel label (Button config) =
    Button { config | label = label }



-- VIEW


view : Button msg -> Html msg
view (Button config) =
    div [ Attr.style "display" "inline" ]
        [ Html.button
            [ Attr.id (buttonId config.label)
            , Attr.style "backgroundColor" config.background
            , Attr.style "color" config.color
            , Attr.style "padding" "0.5em"
            , Attr.style "border-radius" "0.4em"
            , Attr.style "margin-right" "0.4em"
            , Attr.style "outline" "none"
            , Events.onClick config.onClick
            ]
            [ text config.label ]
        ]



-- PRIVATE HELPERS


buttonId : String -> String
buttonId label =
    label |> String.replace " " "-" |> String.toLower |> String.append "button-"


backgroundColorFromMode : Mode -> String
backgroundColorFromMode m =
    case m of
        DarkMode ->
            "#222222"

        LightMode ->
            "white"


colorFromMode : Mode -> String
colorFromMode m =
    case m of
        DarkMode ->
            "#dddddd"

        LightMode ->
            "black"
