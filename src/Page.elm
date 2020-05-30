module Page exposing
    ( Page
    , PageMsg
    , changeRouteTo
    , mapDocument
    , update
    , view
    )

import Browser exposing (Document)
import Effect exposing (Effect(..), mapEffect)
import Env exposing (Env)
import Html exposing (Html, div, nav, node)
import Html.Attributes as Attr
import Page.Counter as Counter
import Page.Home as Home
import Page.NotFound as NotFound
import Page.Settings as Settings
import Route exposing (Route)
import Session exposing (Mode(..), Session(..), getMode)
import View.Link as Link


type Page
    = Home Home.Model
    | Counter Counter.Model
    | Settings Settings.Model
    | NotFound


type PageMsg
    = HomeMsg Home.Msg
    | CounterMsg Counter.Msg
    | SettingsMsg Settings.Msg
    | NavBarMsg NavBarMsg


type NavBarMsg
    = Login
    | Logout
    | ClickLink Route



-- UPDATE


update : PageMsg -> Page -> ( Page, Effect PageMsg )
update msg page =
    case ( msg, page ) of
        ( HomeMsg subMsg, Home model ) ->
            Home.update subMsg model
                |> updateWith Home HomeMsg

        ( CounterMsg subMsg, Counter model ) ->
            Counter.update subMsg model
                |> updateWith Counter CounterMsg

        ( SettingsMsg subMsg, Settings model ) ->
            Settings.update subMsg model
                |> updateWith Settings SettingsMsg

        ( NavBarMsg subMsg, _ ) ->
            case subMsg of
                Login ->
                    ( page, FXLogin )

                Logout ->
                    ( page, FXLogout )

                ClickLink route ->
                    ( page, FXUrlLoad (Route.routeToString route) )

        ( _, _ ) ->
            ( NotFound, FXNone )


updateWith : (pageModel -> Page) -> (pageMsg -> PageMsg) -> ( pageModel, Effect pageMsg ) -> ( Page, Effect PageMsg )
updateWith toPage toMsg ( pageModel, effect ) =
    ( toPage pageModel, mapEffect toMsg effect )



-- VIEW


view : Env -> Page -> Session -> Document PageMsg
view env page session =
    let
        viewDoc =
            viewDocument session

        viewHead =
            viewHeader session page

        viewPage toPageMsg config =
            viewDoc config
                |> mapDocument viewHead toPageMsg
    in
    case page of
        Home _ ->
            viewPage HomeMsg (Home.view env)

        Counter model ->
            viewPage CounterMsg (Counter.view session model)

        Settings model ->
            viewPage SettingsMsg (Settings.view session model)

        NotFound ->
            viewDoc NotFound.view


viewDocument : Session -> { title : String, content : Html msg } -> Document msg
viewDocument session { title, content } =
    { title = title ++ " - My SPA"
    , body =
        [ node "link" [ Attr.rel "stylesheet", Attr.href "/css/main.css" ] []
        , div
            [ Attr.style "position" "relative"
            , Attr.style "min-height" "100vh"
            , Attr.style "padding" "2em"
            , Attr.style "background-color" (backgroundColorFromMode (getMode session))
            , Attr.style "color" (textColorFromMode (getMode session))
            ]
            [ content ]
        ]
    }


viewHeader : Session -> Page -> List (Html PageMsg)
viewHeader session page =
    [ nav [ Attr.class "flex items-center justify-between flex-wrap bg-teal-500 p-6" ]
        [ div [ Attr.class "flex items-center flex-shrink-0 text-white mr-6" ]
            [ div [ Attr.class "w-full flex-grow flex items-center w-auto" ]
                [ div [ Attr.class "text-md flex-grow" ]
                    (List.map (viewLinkHelper page) [ Route.Home, Route.Counter, Route.Settings ])
                ]
            ]
        , div []
            (viewAuthLinks session)
        ]
    ]


viewAuthLinks : Session -> List (Html PageMsg)
viewAuthLinks session =
    case Session.getName session of
        Just name ->
            [ viewLink True True ("Logout " ++ name) (NavBarMsg Logout) ]

        Nothing ->
            [ viewLink True True "Login" (NavBarMsg Login) ]


viewLinkHelper : Page -> Route -> Html PageMsg
viewLinkHelper page route =
    viewLink (isActive page route) False (Route.toLabel route) (NavBarMsg (ClickLink route))



-- PUBLIC HELPERS


changeRouteTo : Maybe Route -> Session -> ( Page, Effect PageMsg )
changeRouteTo maybeRoute session =
    case maybeRoute of
        Just Route.Home ->
            Home.init session
                |> updateWith Home HomeMsg

        Just Route.Counter ->
            Counter.init session
                |> updateWith Counter CounterMsg

        Just Route.Settings ->
            Settings.init session
                |> updateWith Settings SettingsMsg

        Nothing ->
            ( NotFound, FXNone )


mapDocument : List (Html msg2) -> (msg1 -> msg2) -> Document msg1 -> Document msg2
mapDocument header changeMsg { title, body } =
    { title = title, body = header ++ List.map (Html.map changeMsg) body }



-- PRIVATE HELPERS


backgroundColorFromMode : Mode -> String
backgroundColorFromMode m =
    case m of
        DarkMode ->
            "#666666"

        LightMode ->
            "white"


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home _, Route.Home ) ->
            True

        ( Counter _, Route.Counter ) ->
            True

        ( Settings _, Route.Settings ) ->
            True

        _ ->
            False


textColorFromMode : Mode -> String
textColorFromMode m =
    case m of
        DarkMode ->
            "#dddddd"

        LightMode ->
            "black"


viewLink : Bool -> Bool -> String -> msg -> Html msg
viewLink active bounded label msg =
    Link.link
        |> Link.isActive active
        |> Link.isBounded bounded
        |> Link.onClick msg
        |> Link.withLabel label
        |> Link.view
