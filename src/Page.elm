module Page exposing
    ( Page
    , PageMsg
    , changeRouteTo
    , init
    , mapDocument
    , update
    , view
    )

import AppState exposing (AppState(..))
import Browser exposing (Document)
import Effect exposing (Effect(..), mapEffect)
import Env exposing (Env)
import Html exposing (Html, button, div, nav, node, span, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Page.Blank as Blank
import Page.Counter as Counter
import Page.Home as Home
import Page.NotFound as NotFound
import Page.Settings as Settings
import Route exposing (Route)
import Session exposing (Session(..), getMode)
import Svg exposing (path, svg)
import Svg.Attributes exposing (class, d, viewBox)
import ViewHelpers exposing (backgroundColorFromMode, textColorFromMode)



-- MODEL


type Page
    = Blank
    | NotFound
    | Home Home.Model
    | Counter Counter.Model
    | Settings Settings.Model


init : Page
init =
    Blank



-- MESSAGES


type PageMsg
    = HomeMsg Home.Msg
    | CounterMsg Counter.Msg
    | SettingsMsg Settings.Msg
    | NavBarMsg NavBarMsg


type NavBarMsg
    = ToggleMenu



-- UPDATE


{-| Update the page from a message, returning an updated page and effects.
-}
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
                ToggleMenu ->
                    ( page, FXToggleMenu )

        ( _, _ ) ->
            -- Disregard messages that arrive for the wrong page.
            ( NotFound, FXNone )


updateWith : (pageModel -> Page) -> (pageMsg -> PageMsg) -> ( pageModel, Effect pageMsg ) -> ( Page, Effect PageMsg )
updateWith toPage toMsg ( pageModel, effect ) =
    ( toPage pageModel, mapEffect toMsg effect )



-- VIEW


{-| Turns the page into an HTML page.
-}
view : Env -> AppState -> Page -> Document PageMsg
view env state page =
    case state of
        NotReady _ ->
            { title = "", body = [] }

        Ready session ->
            let
                viewDoc =
                    viewDocument session

                viewHeader =
                    viewNavBar session page (Env.openState env)

                viewPage toPageMsg config =
                    viewDoc config
                        |> mapDocument viewHeader toPageMsg
            in
            case page of
                Blank ->
                    viewDoc Blank.view

                NotFound ->
                    viewDoc NotFound.view

                Home _ ->
                    viewPage HomeMsg (Home.view env)

                Counter model ->
                    viewPage CounterMsg (Counter.view session model)

                Settings model ->
                    viewPage SettingsMsg (Settings.view session model)


viewDocument : Session -> { title : String, content : Html msg } -> Document msg
viewDocument session { title, content } =
    { title = title ++ " - My SPA"
    , body =
        [ node "link" [ Attr.rel "stylesheet", Attr.href "/css/main.css" ] []
        , div
            [ Attr.style "position" "relative"
            , Attr.style "min-height" "100vh"
            , Attr.style "background-color" (backgroundColorFromMode (getMode session))
            , Attr.style "color" (textColorFromMode (getMode session))
            ]
            [ viewContent content
            , ViewHelpers.viewFooter
            ]
        ]
    }


viewContent : Html msg -> Html msg
viewContent content =
    div [ Attr.style "padding" "2em" ] [ content ]


viewNavBar : Session -> Page -> Bool -> List (Html PageMsg)
viewNavBar session page isOpen =
    [ nav [ class "flex items-center justify-between flex-wrap bg-teal-500 p-6" ]
        [ div [ class "flex items-center flex-shrink-0 text-white mr-6" ]
            [ span [ class "font-semibold text-xl tracking-tight" ] [ text "My SPA" ] ]
        , div [ class "block lg:hidden" ]
            [ button
                [ class "flex items-center px-3 py-2 border rounded text-teal-200 border-teal-400 hover:text-white hover:border-white"
                , onClick (NavBarMsg ToggleMenu)
                ]
                [ svg [ class "fill-current h-3 w-3", viewBox "0 0 20 20", Attr.attribute "xmlns" "http://www.w3.org/2000/svg" ]
                    [ node "title" [] [ text "Menu" ]
                    , path [ d "M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" ] []
                    ]
                ]
            ]
        , div
            [ Attr.class "w-full block flex-grow lg:flex lg:items-center lg:w-auto" ]
            (if isOpen then
                [ div [ class "text-md lg:flex-grow" ]
                    [ viewRegularLink page Route.Home "Home"
                    , viewRegularLink page Route.Counter "Counter"
                    , viewRegularLink page Route.Settings "Settings"
                    ]
                , div []
                    (case Session.getName session of
                        Just _ ->
                            [ viewAccountLink Route.Home "Logout" ]

                        Nothing ->
                            [ viewAccountLink Route.Home "Login" ]
                    )
                ]

             else
                []
            )
        ]
    ]


viewRegularLink : Page -> Route -> String -> Html msg
viewRegularLink page route id =
    ViewHelpers.navLink (isActive page route) False id (Route.href route)


viewAccountLink : Route -> String -> Html msg
viewAccountLink route id =
    ViewHelpers.navLink True True id (Route.href route)


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



-- PUBLIC HELPERS


{-| Return the page and associated effects associated to a route change.
-}
changeRouteTo : Maybe Route -> AppState -> ( Page, Effect PageMsg )
changeRouteTo maybeRoute state =
    case state of
        NotReady _ ->
            ( Blank, FXNone )

        Ready session ->
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


{-| To generalize the messages produced by the view code, used to transform:
-- (1) Page.Msg to PageMsg (when called from Page module)
-- (2) PageMsg to FrontendMsg (when called from Frontend module)
-}
mapDocument : List (Html msg2) -> (msg1 -> msg2) -> Document msg1 -> Document msg2
mapDocument header changeMsg { title, body } =
    { title = title, body = header ++ List.map (Html.map changeMsg) body }
