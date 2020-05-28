module PageTest exposing (..)

import AppState exposing (AppState(..))
import Frontend
import Html.Attributes exposing (href)
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas, expectViewHasNot)
import Secrets exposing (getSessionKey)
import Session
import Test exposing (..)
import Test.Html.Selector exposing (attribute, id)
import Types exposing (..)


baseUrl =
    "http://localhost:8000/"


guestUser : AppState
guestUser =
    Session.init |> Ready


authenticatedUser : AppState
authenticatedUser =
    Session.init |> Session.signIn getSessionKey "Stephen" |> Ready


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


start : () -> String -> AppState -> ProgramTest FrontendModel FrontendMsg (Cmd FrontendMsg)
start flags initialUrl initialState =
    ProgramTest.createApplication
        { init =
            \_ url _ ->
                Frontend.init (Just initialState) url Nothing
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
            guestUser
                |> start () baseUrl
                |> expectViewHas
                    [ id ("link-" ++ link)
                    , attribute (href ("#/" ++ link))
                    ]
