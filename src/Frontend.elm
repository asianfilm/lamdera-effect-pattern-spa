module Frontend exposing (app, init, perform, update, view)

import Browser exposing (Document, UrlRequest(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Effect exposing (Effect(..), mapEffect)
import Env
import Lamdera
import Page exposing (Page, PageMsg)
import Route exposing (Route(..))
import Session exposing (Session, init)
import Task
import Time
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..), ToFrontend(..))
import Url



-- MODEL


app =
    Lamdera.frontend
        { init =
            \url key ->
                init Session.init url (Just key)
                    |> perform FrontendIgnored
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update =
            \msg model ->
                update msg model
                    |> perform FrontendIgnored
        , updateFromBackend =
            \msg model ->
                updateFromBackend msg model
                    |> perform FrontendIgnored
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Session -> Url.Url -> Maybe Nav.Key -> ( FrontendModel, Effect FrontendMsg )
init session url navKey =
    let
        ( model, effect ) =
            changeRouteTo (Route.fromUrl url)
                { env = Env.init navKey Time.utc
                , session = session
                , page = Page.init
                }
    in
    ( model, FXBatch [ effect, FXRequestSession ] )



-- UPDATE


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
update msg model =
    case msg of
        FrontendIgnored _ ->
            ( model, FXNone )

        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, FXPushUrl url )

                External url ->
                    ( model, FXLoadUrl url )

        UrlChanged url ->
            changeRouteTo (Route.fromUrl url) model

        GotPageMsg pageMsg ->
            Page.update pageMsg model.page
                |> fromPage model

        GotTimeZone timeZone ->
            ( { model | env = Env.updateTimeZone timeZone model.env }, FXNone )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
updateFromBackend msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, FXNone )



-- EFFECTS


perform : (String -> msg) -> ( FrontendModel, Effect msg ) -> ( FrontendModel, Cmd msg )
perform ignore ( model, effect ) =
    case effect of
        FXNone ->
            ( model, Cmd.none )

        FXBatch effects ->
            List.foldl (batchEffect ignore) ( model, [] ) effects
                |> Tuple.mapSecond Cmd.batch

        FXReplaceUrl route ->
            case ( Env.devMode model.env, Env.navKey model.env ) of
                ( Env.NotTest, Just navKey ) ->
                    ( model, Route.replaceUrl navKey route )

                _ ->
                    ( model, Cmd.none )

        FXPushUrl url ->
            case ( Env.devMode model.env, Env.navKey model.env ) of
                ( Env.NotTest, Just navKey ) ->
                    ( model, Nav.pushUrl navKey (Url.toString url) )

                _ ->
                    ( model, Cmd.none )

        FXLoadUrl href ->
            ( model, Nav.load href )

        FXRequestSession ->
            ( model, Lamdera.sendToBackend RequestSession )

        FXUpdateSessionCounter i ->
            ( model, Lamdera.sendToBackend (SaveCounter i) )

        FXUpdateSessionMode mode ->
            ( model, Lamdera.sendToBackend (SaveMode mode) )

        FXGetTimeZone toMsg ->
            ( model, Task.perform toMsg Time.here )

        FXScrollToTop ->
            ( model, Task.perform (\_ -> ignore "scrollToTop") <| Dom.setViewport 0 0 )


batchEffect : (String -> msg) -> Effect msg -> ( FrontendModel, List (Cmd msg) ) -> ( FrontendModel, List (Cmd msg) )
batchEffect ignore effect ( model, cmds ) =
    perform ignore ( model, effect )
        |> Tuple.mapSecond (\cmd -> cmd :: cmds)



-- VIEW


view : FrontendModel -> Document FrontendMsg
view model =
    Page.view model.session model.page
        |> Page.mapDocument GotPageMsg



-- HELPERS


changeRouteTo : Maybe Route -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
changeRouteTo route model =
    Page.changeRouteTo route model.session model.page
        |> fromPage model


fromPage : FrontendModel -> ( Page, Effect PageMsg ) -> ( FrontendModel, Effect FrontendMsg )
fromPage model ( page, effect ) =
    ( { model | page = page }
    , mapEffect GotPageMsg effect
    )
