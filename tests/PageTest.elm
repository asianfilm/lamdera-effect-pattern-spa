module PageTest exposing (..)

import App
import Env
import Frontend
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas, expectViewHasNot)
import Secrets exposing (getSessionKey)
import Session exposing (Session)
import Test exposing (..)
import Test.Html.Selector exposing (id, text)
import Time
import Types exposing (..)


suite : Test
suite =
    describe "page tests"
        [ describe "header test"
            [ testNavigationLink "counter"
            , testNavigationLink "settings"
            ]
        , describe "home page"
            [ test "home page has clock" <|
                \() ->
                    guestUser
                        |> start () (baseUrl ++ "#")
                        |> expectViewHas
                            [ id "clock"
                            , text "The time is 06:21"
                            ]
            ]
        , describe "login"
            [ test "home page has login button for guest user" <|
                \() ->
                    guestUser
                        |> start () (baseUrl ++ "#")
                        |> expectViewHas
                            [ id "button-login" ]
            , test "home page has logout button for authenticated user" <|
                \() ->
                    authenticatedUser
                        |> start () (baseUrl ++ "#")
                        |> expectViewHas
                            [ id "button-logout-stephen" ]
            ]
        , describe "settings page"
            [ test "settings page has dark mode button" <|
                \() ->
                    guestUser
                        |> start () (baseUrl ++ "#/settings")
                        |> expectViewHas
                            [ id "button-dark-mode" ]
            , test "clicking dark mode button removes it" <|
                \() ->
                    guestUser
                        |> start () (baseUrl ++ "#/settings")
                        |> clickButton "Dark Mode"
                        |> expectViewHasNot
                            [ id "button-dark-mode" ]
            , test "clicking dark mode button adds a light mode button" <|
                \() ->
                    guestUser
                        |> start () (baseUrl ++ "#/settings")
                        |> clickButton "Dark Mode"
                        |> expectViewHas
                            [ id "button-light-mode" ]
            ]
        ]



-- HELPERS


baseUrl =
    "http://localhost:8000/"


guestUser : ( Session, Env.LocalTime )
guestUser =
    ( Session.init, ( Time.millisToPosix 1590819692000, Time.utc ) )


authenticatedUser : ( Session, Env.LocalTime )
authenticatedUser =
    ( Session.init |> Session.signIn getSessionKey "Stephen", ( Time.millisToPosix 1590819692000, Time.utc ) )


start : () -> String -> ( Session, Env.LocalTime ) -> ProgramTest FrontendModel FrontendMsg (Cmd FrontendMsg)
start flags testUrl testSetup =
    ProgramTest.createApplication
        { init =
            \_ url _ ->
                Frontend.init (Just testSetup) url Nothing
                    |> App.perform Ignored
        , view = Frontend.view
        , update =
            \msg model ->
                Frontend.update msg model
                    |> App.perform Ignored
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlClicked
        }
        |> ProgramTest.withBaseUrl testUrl
        |> ProgramTest.start flags


testNavigationLink : String -> Test
testNavigationLink link =
    test ("link to \"" ++ link ++ "\" page in navigation bar") <|
        \() ->
            guestUser
                |> start () baseUrl
                |> expectViewHas
                    [ id ("link-" ++ link) ]
