module View.Button exposing (button, onClick, view, withLabel, withMode)

import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attr
import Html.Events as Events
import Session exposing (Mode(..))


type Button msg
    = Button
        { label : String
        , mode : Maybe Mode
        , onClick : msg
        }



-- BUILDERS


button : Button ()
button =
    Button
        { label = ""
        , mode = Nothing
        , onClick = ()
        }


onClick : msgB -> Button msgA -> Button msgB
onClick onClick_ (Button config) =
    Button
        { label = config.label
        , mode = config.mode
        , onClick = onClick_
        }


withMode : Mode -> Button msg -> Button msg
withMode m (Button config) =
    Button { config | mode = Just m }


withLabel : String -> Button msg -> Button msg
withLabel label (Button config) =
    Button { config | label = label }



-- VIEW


view : Button msg -> Html msg
view (Button config) =
    div [ Attr.style "display" "inline" ]
        [ Html.button
            (commonStyling (Button config) ++ modeStyling (Button config))
            [ text config.label ]
        ]



-- STYLES


commonStyling : Button msg -> List (Attribute msg)
commonStyling (Button config) =
    [ Attr.id (config.label |> String.replace " " "-" |> String.toLower |> String.append "button-")
    , Attr.style "outline" "none"
    , Events.onClick config.onClick
    ]


modeStyling : Button msg -> List (Attribute msg)
modeStyling (Button config) =
    case config.mode of
        Just LightMode ->
            [ Attr.class "bg-white hover:bg-gray-100 text-gray-800 py-2 px-4 border border-gray-400 rounded shadow" ]

        Just DarkMode ->
            [ Attr.class "bg-black hover:bg-gray-100 text-gray-200 py-2 px-4 border border-gray-600 rounded shadow" ]

        Nothing ->
            [ Attr.class "block inline-block mt-0 text-teal-200 mr-4"
            , Attr.class "inline-block text-sm px-4 py-2 leading-none border rounded text-white border-white hover:border-transparent hover:text-teal-500 hover:bg-white"
            ]
