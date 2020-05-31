module View.Link exposing (isActive, link, view, withAnchor, withLabel)

import Html exposing (Attribute, Html, a, text)
import Html.Attributes as Attr


type Link msg
    = Link
        { anchor : Attribute msg
        , active : Bool
        , label : String
        }



-- BUILDERS


link : Link ()
link =
    Link
        { anchor = Attr.href ""
        , active = False
        , label = ""
        }


isActive : Bool -> Link msg -> Link msg
isActive active (Link config) =
    Link { config | active = active }


withAnchor : Attribute msg -> Link () -> Link msg
withAnchor href (Link config) =
    Link
        { anchor = href
        , active = config.active
        , label = config.label
        }


withLabel : String -> Link msg -> Link msg
withLabel label (Link config) =
    Link { config | label = label }



-- VIEW


view : Link msg -> Html msg
view (Link config) =
    a
        [ Attr.id (config.label |> String.replace " " "-" |> String.toLower |> String.append "link-")
        , Attr.class "block inline-block mt-0 text-teal-200 mr-4"
        , Attr.classList [ ( "hover:text-white", not config.active ) ]
        , config.anchor
        ]
        [ text config.label ]
