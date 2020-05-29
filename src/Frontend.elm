module Frontend exposing (app, init, update, view)

import App
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Effect exposing (Effect(..), mapEffect)
import Env exposing (Env)
import Page exposing (Page, PageMsg)
import Route exposing (Route(..))
import Session exposing (Session)
import Time
import Types exposing (AppState(..), FrontendModel, FrontendMsg(..), ToBackend(..), ToFrontend(..))
import Url


app =
    App.app
        { init = init
        , view = view
        , update = update
        , updateFromBackend = updateFromBackend
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlClicked
        , subscriptions = \_ -> Time.every (60 * 1000) Tick
        }



-- INIT


{-| The init function behaves differently in different modes
-- (1) Testing: init starts with a session, but usually without a navigation key
-- (2) Production or development: no initial session, which is immediately requested
-}
init : Maybe Session -> Url.Url -> Maybe Nav.Key -> ( FrontendModel, Effect FrontendMsg )
init maybeSession url navKey =
    let
        ( env, commonEffects ) =
            ( Env.init navKey, [ FXTimeNowRQ Tick, FXTimeZoneRQ GotTimeZone ] )
    in
    case maybeSession of
        Just session ->
            initTesting url env commonEffects session

        Nothing ->
            ( { env = env, state = NotReady url }
            , FXBatch (FXSessionRQ :: commonEffects)
            )


initTesting : Url.Url -> Env -> List (Effect FrontendMsg) -> Session -> ( FrontendModel, Effect FrontendMsg )
initTesting url env effects session =
    let
        ( testModel, initialPageEffect ) =
            changeRouteTo (Route.fromUrl url) env session
    in
    ( testModel, FXBatch (initialPageEffect :: effects) )



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
            model |> updateIfAppReady (\_ s -> changeRouteTo (Route.fromUrl url) model.env s)

        GotPageMsg pageMsg ->
            model |> updateIfAppReady (\p s -> Page.update pageMsg p |> fromPage model.env s)

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



-- VIEW


view : FrontendModel -> Document FrontendMsg
view model =
    model |> viewIfAppReady (\p s -> Page.view model.env p s |> Page.mapDocument [] GotPageMsg)



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


ifAppReady : (FrontendModel -> a) -> (Page -> Session -> a) -> FrontendModel -> a
ifAppReady failure success model =
    case model.state of
        NotReady _ ->
            failure model

        Ready ( page, session ) ->
            success page session


updateIfAppReady : (Page -> Session -> ( FrontendModel, Effect FrontendMsg )) -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
updateIfAppReady =
    ifAppReady (\m -> ( m, FXNone ))


viewIfAppReady : (Page -> Session -> Document FrontendMsg) -> FrontendModel -> Document FrontendMsg
viewIfAppReady =
    ifAppReady (\_ -> { title = "", body = [] })
