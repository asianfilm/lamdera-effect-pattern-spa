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
import Session exposing (Session(..), getMode)
import View.Helpers exposing (backgroundColorFromMode, textColorFromMode)
import View.Link as Link



-- MODEL


type Page
    = Home Home.Model
    | Counter Counter.Model
    | Settings Settings.Model
    | NotFound



-- MESSAGES


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
                Login ->
                    ( page, FXLogin )

                Logout ->
                    ( page, FXLogout )

                ClickLink route ->
                    ( page, FXUrlReplace route )

        ( _, _ ) ->
            ( NotFound, FXNone )


updateWith : (pageModel -> Page) -> (pageMsg -> PageMsg) -> ( pageModel, Effect pageMsg ) -> ( Page, Effect PageMsg )
updateWith toPage toMsg ( pageModel, effect ) =
    ( toPage pageModel, mapEffect toMsg effect )



-- VIEW


{-| Turns the page into an HTML page.
-}
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
                    (List.map (viewLink page) [ Route.Home, Route.Counter, Route.Settings ])
                ]
            ]
        , div []
            (viewAuthLinks session)
        ]
    ]


viewAuthLink : String -> PageMsg -> Html PageMsg
viewAuthLink label msg =
    Link.link
        |> Link.isActive True
        |> Link.isBounded True
        |> Link.onClick msg
        |> Link.withLabel label
        |> Link.view


viewAuthLinks : Session -> List (Html PageMsg)
viewAuthLinks session =
    case Session.getName session of
        Just name ->
            [ viewAuthLink ("Logout " ++ name) (NavBarMsg Logout) ]

        Nothing ->
            [ viewAuthLink "Login" (NavBarMsg Login) ]


viewLink : Page -> Route -> Html PageMsg
viewLink page route =
    Link.link
        |> Link.isActive (isActive page route)
        |> Link.withLabel (Route.toString route)
        |> Link.onClick (NavBarMsg (ClickLink route))
        |> Link.view



-- PRIVATE HELPERS


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


{-| To generalize the messages produced by the view code, used to transform:
-- (1) Page.Msg to PageMsg (when called from Page module)
-- (2) PageMsg to FrontendMsg (when called from Frontend module)
-}
mapDocument : List (Html msg2) -> (msg1 -> msg2) -> Document msg1 -> Document msg2
mapDocument header changeMsg { title, body } =
    { title = title, body = header ++ List.map (Html.map changeMsg) body }
