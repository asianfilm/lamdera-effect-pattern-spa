module Page exposing
    ( Page
    , PageMsg
    , changeRouteTo
    , init
    , mapDocument
    , update
    , view
    )

import Browser exposing (Document)
import Effect exposing (Effect(..), mapEffect)
import Env exposing (Env)
import Html exposing (Html, a, div, li, node, text, ul)
import Html.Attributes exposing (href, rel, style)
import Page.Blank as Blank
import Page.Counter as Counter
import Page.Home as Home
import Page.NotFound as NotFound
import Page.Settings as Settings
import Route exposing (Route(..))
import Session exposing (Session(..), getMode)
import ViewHelpers exposing (backgroundColorFromMode, textColorFromMode)



-- MODEL


type Page
    = BlankPage
    | NotFoundPage
    | HomePage
    | CounterPage Counter.Model
    | SettingsPage Settings.Model


init : Page
init =
    BlankPage



-- UPDATE


type PageMsg
    = GotCounterMsg Counter.Msg
    | GotSettingsMsg Settings.Msg


{-| Update the page from a message, returning an updated page and effects.
-}
update : PageMsg -> Page -> ( Page, Effect PageMsg )
update msg page =
    case ( msg, page ) of
        ( GotCounterMsg subMsg, CounterPage model ) ->
            Counter.update subMsg model
                |> updateWith CounterPage GotCounterMsg

        ( GotSettingsMsg subMsg, SettingsPage model ) ->
            Settings.update subMsg model
                |> updateWith SettingsPage GotSettingsMsg

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( NotFoundPage, FXNone )


{-| Return the page and associated effects associated to a route change.
-}
changeRouteTo : Maybe Route -> Session -> Page -> ( Page, Effect PageMsg )
changeRouteTo maybeRoute session page =
    case maybeRoute of
        Just RouteHome ->
            ( page, FXNone )

        Just RouteCounter ->
            Counter.init session
                |> updateWith CounterPage GotCounterMsg

        Just RouteSettings ->
            Settings.init session
                |> updateWith SettingsPage GotSettingsMsg

        Nothing ->
            ( NotFoundPage, FXNone )


updateWith :
    (pageModel -> Page)
    -> (pageMsg -> PageMsg)
    -> ( pageModel, Effect pageMsg )
    -> ( Page, Effect PageMsg )
updateWith toPage toMsg ( pageModel, effect ) =
    ( toPage pageModel
    , mapEffect toMsg effect
    )



-- VIEW


{-| Turns the page into an HTML page.
-}
view : Env -> Session -> Page -> Document PageMsg
view _ session page =
    let
        viewPage toPageMsg config =
            viewDocument session page config
                |> mapDocument toPageMsg
    in
    case page of
        BlankPage ->
            viewDocument session page Blank.view

        NotFoundPage ->
            viewDocument session page NotFound.view

        HomePage ->
            viewDocument session page Home.view

        CounterPage model ->
            viewPage GotCounterMsg (Counter.view session model)

        SettingsPage model ->
            viewPage GotSettingsMsg (Settings.view session model)


viewDocument : Session -> Page -> { title : String, content : Html msg } -> Document msg
viewDocument session page { title, content } =
    { title = title ++ " - My SPA"
    , body =
        [ node "link" [ rel "stylesheet", href "/reset.css" ] []
        , div
            [ style "position" "relative"
            , style "min-height" "100vh"
            , style "background-color" (backgroundColorFromMode (getMode session))
            , style "color" (textColorFromMode (getMode session))
            ]
            [ viewHeader session page
            , viewContent content
            , viewFooter
            ]
        ]
    }


viewContent : Html msg -> Html msg
viewContent content =
    div [ style "margin" "2em" ] [ content ]


viewHeader : Session -> Page -> Html msg
viewHeader _ page =
    div []
        [ ul [ style "list-style-type" "none", style "overflow" "hidden" ]
            (List.reverse
                [ navbarLink page RouteHome [ text "Home" ]
                , navbarLink page RouteCounter [ text "Counter" ]
                , navbarLink page RouteSettings [ text "Settings" ]
                ]
            )
        ]


navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ style "float" "right", style "padding" "1em" ]
        (case ( page, route ) of
            ( HomePage, RouteHome ) ->
                linkContent

            ( CounterPage _, RouteCounter ) ->
                linkContent

            ( SettingsPage _, RouteSettings ) ->
                linkContent

            _ ->
                [ a
                    [ Route.href route
                    , style "color" "inherit"
                    , style "text-decoration" "none"
                    ]
                    linkContent
                ]
        )


viewFooter : Html msg
viewFooter =
    div [ style "position" "absolute", style "margin-left" "2em", style "width" "100%", style "bottom" "0", style "height" "2em" ]
        [ text "Based on "
        , a [ href "https://github.com/dmy/elm-realworld-example-app" ]
            [ text "Elm RealWorld Example" ]
        ]



-- PUBLIC HELPERS


{-| Transform the messages produced by the page.
-}
mapDocument : (msg1 -> msg2) -> Document msg1 -> Document msg2
mapDocument changeMsg { title, body } =
    { title = title, body = List.map (Html.map changeMsg) body }
