module Frontend exposing (app, init, perform, update, view)

import AppState exposing (AppState(..))
import Browser exposing (Document, UrlRequest(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Effect exposing (Effect(..), mapEffect)
import Env exposing (navKey)
import Lamdera
import Page exposing (Page, PageMsg)
import Route exposing (Route(..))
import Task
import Time
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..), ToFrontend(..))
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


init : Maybe AppState -> Url.Url -> Maybe Nav.Key -> ( FrontendModel, Effect FrontendMsg )
init state url navKey =
    let
        model =
            { env = Env.init navKey
            , page = Page.init
            , state = state |> Maybe.withDefault (NotReady url)
            }

        commonEffects =
            [ FXTimeNowRQ Tick, FXTimeZoneRQ GotTimeZone ]
    in
    if state == Nothing then
        ( model, FXBatch (FXStateRQ :: commonEffects) )

    else
        let
            ( pageModel, pageEffect ) =
                model |> changeRouteTo (Route.fromUrl url)
        in
        ( pageModel, FXBatch (pageEffect :: commonEffects) )



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
            changeRouteTo (Route.fromUrl url) model

        GotPageMsg pageMsg ->
            Page.update pageMsg model.page
                |> fromPage model

        GotTimeZone timeZone ->
            ( { model | env = Env.setTimeZone timeZone model.env }, FXNone )

        Tick newTime ->
            ( { model | env = Env.setTime newTime model.env }, FXNone )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
updateFromBackend msg model =
    case msg of
        B2FSession session ->
            let
                statefulModel =
                    { model | state = Ready session }
            in
            case model.state of
                NotReady url ->
                    statefulModel |> changeRouteTo (Route.fromUrl url)

                Ready _ ->
                    ( statefulModel, FXNone )



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
    Page.view model.env model.state model.page
        |> Page.mapDocument [] GotPageMsg



-- HELPERS


changeRouteTo : Maybe Route -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
changeRouteTo route model =
    Page.changeRouteTo route model.state
        |> fromPage model


fromPage : FrontendModel -> ( Page, Effect PageMsg ) -> ( FrontendModel, Effect FrontendMsg )
fromPage model ( page, effect ) =
    ( { model | page = Just page }
    , mapEffect GotPageMsg effect
    )
