module Route exposing (Route(..), fromUrl, href, pushUrl, replaceUrl, toLabel)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Builder
import Url.Parser as Parser exposing (Parser, oneOf, s)



-- MODEL


type Route
    = Home
    | Counter
    | Settings



-- ROUTING


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Counter (s "counter")
        , Parser.map Settings (s "settings")
        ]



-- PUBLIC HELPERS


fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


pushUrl : String -> Nav.Key -> Cmd msg
pushUrl url key =
    Nav.pushUrl key url


replaceUrl : Route -> Nav.Key -> Cmd msg
replaceUrl route key =
    Nav.replaceUrl key (routeToString route)


toLabel : Route -> String
toLabel route =
    case route of
        Home ->
            "Home"

        Counter ->
            "Counter"

        Settings ->
            "Settings"



-- PRIVATE HELPERS


routeToString : Route -> String
routeToString page =
    Url.Builder.relative ("#" :: routeToPieces page) []


routeToPieces : Route -> List String
routeToPieces route =
    case route of
        Home ->
            []

        Counter ->
            [ "counter" ]

        Settings ->
            [ "settings" ]
