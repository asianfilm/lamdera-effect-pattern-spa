module View.Link exposing (isActive, isBounded, link, onClick, view, withLabel)

import Html exposing (Html, div, text)
import Html.Attributes as Attr
import Html.Events as Events


type Link msg
    = Link
        { isActive : Bool
        , isBounded : Bool
        , label : String
        , onClick : msg
        }


link : Link ()
link =
    Link
        { isActive = False
        , isBounded = False
        , label = ""
        , onClick = ()
        }


isActive : Bool -> Link msg -> Link msg
isActive active (Link config) =
    Link { config | isActive = active }


isBounded : Bool -> Link msg -> Link msg
isBounded bounded (Link config) =
    Link { config | isBounded = bounded }


onClick : msg -> Link () -> Link msg
onClick onClick_ (Link config) =
    Link
        { isActive = config.isActive
        , isBounded = config.isBounded
        , label = config.label
        , onClick = onClick_
        }


withLabel : String -> Link msg -> Link msg
withLabel label (Link config) =
    Link { config | label = label }


view : Link msg -> Html msg
view (Link config) =
    div
        [ Attr.id (config.label |> String.replace " " "-" |> String.toLower |> String.append "link-")
        , Attr.class "block inline-block mt-0 text-teal-200 mr-4"
        , Attr.classList [ ( "hover:text-white", not config.isActive ) ]
        , Attr.classList [ ( "inline-block text-sm px-4 py-2 leading-none border rounded text-white border-white hover:border-transparent hover:text-teal-500 hover:bg-white", config.isBounded ) ]
        , Events.onClick config.onClick
        ]
        [ text config.label ]
