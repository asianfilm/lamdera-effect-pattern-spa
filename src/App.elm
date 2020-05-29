module App exposing (app, perform)

import Browser.Dom as Dom
import Browser.Navigation as Nav
import Effect exposing (Effect(..))
import Env exposing (Env)
import Lamdera
import Route
import Task
import Time
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..))
import Url


app config =
    Lamdera.frontend
        { init = \url key -> config.init Nothing url (Just key) |> perform Ignored
        , view = config.view
        , update = \msg model -> config.update msg model |> perform Ignored
        , updateFromBackend = \msg model -> config.updateFromBackend msg model |> perform Ignored
        , subscriptions = config.subscriptions
        , onUrlChange = config.onUrlChange
        , onUrlRequest = config.onUrlRequest
        }


batchEffect : (String -> msg) -> Effect msg -> ( FrontendModel, List (Cmd msg) ) -> ( FrontendModel, List (Cmd msg) )
batchEffect ignore effect ( model, cmds ) =
    perform ignore ( model, effect )
        |> Tuple.mapSecond (\cmd -> cmd :: cmds)


ifNavKey : Env -> (Nav.Key -> Cmd msg) -> Cmd msg
ifNavKey env cmd =
    case Env.navKey env of
        Nothing ->
            Cmd.none

        Just key ->
            cmd key


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

        -- Routing
        FXUrlLoad href ->
            ( model, Nav.load href )

        FXUrlPush url ->
            ( model, ifNavKey model.env <| Route.pushUrl (Url.toString url) )

        FXUrlReplace route ->
            ( model, ifNavKey model.env <| Route.replaceUrl route )

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
