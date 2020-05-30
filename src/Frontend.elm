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
        , subscriptions = \_ -> Time.every (60 * 1000) GotTick
        }



-- INIT


{-| The init function behaves differently in different modes
-- (1) Testing: init starts with a session, but usually without a navigation key
-- (2) Production or development: no initial session, which is immediately requested
-}
init : Maybe ( Session, Env.LocalTime ) -> Url.Url -> Maybe Nav.Key -> ( FrontendModel, Effect FrontendMsg )
init testSetup url navKey =
    case testSetup of
        Just ( session, localTime ) ->
            changeRouteTo (Route.fromUrl url) (Env.init navKey (Just localTime)) session

        Nothing ->
            ( { env = Env.init navKey Nothing, state = NotReady url ( Nothing, Nothing ) }
            , FXBatch [ FXSessionRQ, FXTimeNowRQ GotTick, FXTimeZoneRQ GotTimeZone ]
            )



-- UPDATE


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
update msg model =
    case model.state of
        NotReady url ( t, tz ) ->
            case msg of
                GotTimeZone timeZone ->
                    ( { model | state = NotReady url ( t, Just timeZone ) }, FXNone )

                GotTick newTime ->
                    ( { model | state = NotReady url ( Just (Time.posixToMillis newTime), tz ) }, FXNone )

                _ ->
                    ( model, FXNone )

        Ready ( page, session ) ->
            case msg of
                Ignored _ ->
                    ( model, FXNone )

                GotPageMsg pageMsg ->
                    Page.update pageMsg page |> fromPage model.env session

                GotTick newTime ->
                    ( { model | env = Env.setTime newTime model.env }, FXNone )

                GotTimeZone timeZone ->
                    ( { model | env = Env.setTimeZone timeZone model.env }, FXNone )

                UrlClicked urlRequest ->
                    case urlRequest of
                        Internal url ->
                            ( model, FXUrlPush url )

                        External url ->
                            ( model, FXUrlLoad url )

                UrlChanged url ->
                    changeRouteTo (Route.fromUrl url) model.env session


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )
updateFromBackend msg model =
    case msg of
        B2FSession session ->
            case model.state of
                NotReady url localTime ->
                    let
                        newEnv =
                            model.env |> Env.setTimeWithZone localTime
                    in
                    changeRouteTo (Route.fromUrl url) newEnv session

                Ready ( page, _ ) ->
                    ( { model | state = Ready ( page, session ) }, FXNone )



-- VIEW


view : FrontendModel -> Document FrontendMsg
view model =
    case model.state of
        NotReady _ _ ->
            { title = "", body = [] }

        Ready ( page, session ) ->
            Page.view model.env page session |> Page.mapDocument [] GotPageMsg



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
