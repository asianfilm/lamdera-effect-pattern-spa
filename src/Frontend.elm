module Frontend exposing (app, init, perform, update, view)

import Browser exposing (Document, UrlRequest(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Effect exposing (Effect(..), mapEffect)
import Env exposing (Env, navKey)
import Lamdera
import Page exposing (Page, PageMsg)
import Route exposing (Route(..))
import Session exposing (Session)
import Task
import Time
import Types exposing (AppState(..), FrontendModel, FrontendMsg(..), ToBackend(..), ToFrontend(..))
import Url



-- MODEL


app =
    Lamdera.frontend
        { init =
            \url key ->
                init Nothing url (Just key)
                    |> perform Ignored
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update =
            \msg model ->
                update msg model
                    |> perform Ignored
        , updateFromBackend =
            \msg model ->
                updateFromBackend msg model
                    |> perform Ignored
        , subscriptions = subscriptions
        , view = view
        }


init : Maybe Session -> Url.Url -> Maybe Nav.Key -> ( FrontendModel, Effect FrontendMsg )
init maybeSession url navKey =
    let
        env =
            Env.init navKey

        commonEffects =
            [ FXTimeNowRQ Tick, FXTimeZoneRQ GotTimeZone ]
    in
    case maybeSession of
        Nothing ->
            ( { env = env, state = NotReady url }
            , FXBatch (FXStateRQ :: commonEffects)
            )

        Just session ->
            let
                ( model, initialPageEffect ) =
                    changeRouteTo (Route.fromUrl url) env session
            in
            ( model, FXBatch (initialPageEffect :: commonEffects) )



-- SUBSCRIPTIONS


subscriptions : FrontendModel -> Sub FrontendMsg
subscriptions _ =
    Time.every (60 * 1000) Tick



-- UPDATE


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
update msg model =
    case msg of
        Ignored _ ->
            ( model, FXNone )

        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, FXUrlPush url )

                External url ->
                    ( model, FXUrlLoad url )

        UrlChanged url ->
            case model.state of
                NotReady _ ->
                    ( model, FXNone )

                Ready ( _, session ) ->
                    changeRouteTo (Route.fromUrl url) model.env session

        GotPageMsg pageMsg ->
            case model.state of
                NotReady _ ->
                    ( model, FXNone )

                Ready ( page, session ) ->
                    Page.update pageMsg page
                        |> fromPage model.env session

        GotTimeZone timeZone ->
            ( { model | env = Env.setTimeZone timeZone model.env }, FXNone )

        Tick newTime ->
            ( { model | env = Env.setTime newTime model.env }, FXNone )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
updateFromBackend msg model =
    case msg of
        B2FSession session ->
            case model.state of
                NotReady url ->
                    changeRouteTo (Route.fromUrl url) model.env session

                Ready ( page, _ ) ->
                    ( { model | state = Ready ( page, session ) }, FXNone )



-- EFFECTS


perform : (String -> msg) -> ( FrontendModel, Effect msg ) -> ( FrontendModel, Cmd msg )
perform ignore ( model, effect ) =
    case effect of
        FXNone ->
            ( model, Cmd.none )

        FXBatch effects ->
            List.foldl (batchEffect ignore) ( model, [] ) effects
                |> Tuple.mapSecond Cmd.batch

        -- Requests
        FXStateRQ ->
            ( model, Lamdera.sendToBackend F2BSessionRQ )

        FXTimeNowRQ toMsg ->
            ( model, Task.perform toMsg Time.now )

        FXTimeZoneRQ toMsg ->
            ( model, Task.perform toMsg Time.here )

        -- Session
        FXLogin ->
            ( model, Lamdera.sendToBackend F2BLogin )

        FXLogout ->
            ( model, Lamdera.sendToBackend F2BLogout )

        FXSaveCounter i ->
            ( model, Lamdera.sendToBackend (F2BSaveCounter i) )

        FXSaveMode mode ->
            ( model, Lamdera.sendToBackend (F2BSaveMode mode) )

        -- UI
        FXScrollToTop ->
            ( model, Task.perform (\_ -> ignore "scrollToTop") <| Dom.setViewport 0 0 )

        -- Url
        FXUrlLoad href ->
            ( model, Nav.load href )

        FXUrlPush url ->
            case Env.navKey model.env of
                Nothing ->
                    ( model, Cmd.none )

                Just key ->
                    ( model, Nav.pushUrl key (Url.toString url) )

        FXUrlReplace route ->
            case Env.navKey model.env of
                Nothing ->
                    ( model, Cmd.none )

                Just key ->
                    ( model, Route.replaceUrl key route )


batchEffect : (String -> msg) -> Effect msg -> ( FrontendModel, List (Cmd msg) ) -> ( FrontendModel, List (Cmd msg) )
batchEffect ignore effect ( model, cmds ) =
    perform ignore ( model, effect )
        |> Tuple.mapSecond (\cmd -> cmd :: cmds)



-- VIEW


view : FrontendModel -> Document FrontendMsg
view model =
    case model.state of
        NotReady _ ->
            { title = "", body = [] }

        Ready ( page, session ) ->
            Page.view model.env page session
                |> Page.mapDocument [] GotPageMsg



-- HELPERS


changeRouteTo : Maybe Route -> Env -> Session -> ( FrontendModel, Effect FrontendMsg )
changeRouteTo route env session =
    Page.changeRouteTo route session
        |> fromPage env session


fromPage : Env -> Session -> ( Page, Effect PageMsg ) -> ( FrontendModel, Effect FrontendMsg )
fromPage env session ( page, effect ) =
    ( { env = env, state = Ready ( page, session ) }
    , mapEffect GotPageMsg effect
    )
