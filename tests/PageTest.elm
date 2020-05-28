module PageTest exposing (..)

import Frontend
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas, expectViewHasNot)
import Secrets exposing (getSessionKey)
import Session exposing (Session)
import Test exposing (..)
import Test.Html.Selector exposing (id)
import Types exposing (..)


baseUrl =
    "http://localhost:8000/"


guestUserSession : Session
guestUserSession =
    Session.init


authenticatedUser : Session
authenticatedUser =
    Session.init |> Session.signIn getSessionKey "Stephen"


suite : Test
suite =
    describe "page tests"
        [ describe "header test"
            [ testNavigationLink "counter"
            , testNavigationLink "settings"
            ]
        , describe "settings page"
            [ test "settings page has dark mode button" <|
                \() ->
                    guestUserSession
                        |> start () (baseUrl ++ "#/settings")
                        |> expectViewHas
                            [ id "button-dark-mode" ]
            , test "clicking dark mode button removes it" <|
                \() ->
                    guestUserSession
                        |> start () (baseUrl ++ "#/settings")
                        |> clickButton "Dark Mode"
                        |> expectViewHasNot
                            [ id "button-dark-mode" ]
            , test "clicking dark mode button adds a light mode button" <|
                \() ->
                    guestUserSession
                        |> start () (baseUrl ++ "#/settings")
                        |> clickButton "Dark Mode"
                        |> expectViewHas
                            [ id "button-light-mode" ]
            ]
        ]


start : () -> String -> Session -> ProgramTest FrontendModel FrontendMsg (Cmd FrontendMsg)
start flags initialUrl initialSession =
    ProgramTest.createApplication
        { init =
            \_ url _ ->
                Frontend.init (Just initialSession) url Nothing
                    |> Frontend.perform Ignored
        , view = Frontend.view
        , update =
            \msg model ->
                Frontend.update msg model
                    |> Frontend.perform Ignored
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        }
        |> ProgramTest.withBaseUrl initialUrl
        |> ProgramTest.start flags


testNavigationLink : String -> Test
testNavigationLink link =
    test ("link to \"" ++ link ++ "\" page in navigation bar") <|
        \() ->
            guestUserSession
                |> start () baseUrl
                |> expectViewHas
                    [ id ("link-" ++ link) ]
