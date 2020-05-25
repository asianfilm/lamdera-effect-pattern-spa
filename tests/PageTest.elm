module PageTest exposing (..)

import Frontend
import Html.Attributes exposing (href)
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas, expectViewHasNot)
import Session
import Test exposing (..)
import Test.Html.Selector exposing (attribute, id)
import Types exposing (..)


baseUrl =
    "http://localhost:8000/"


suite : Test
suite =
    describe "page tests"
        [ describe "header test"
            [ testNavigationLink "counter"
            , testNavigationLink "settings"
            ]
        , describe "footer test"
            [ test "every page has link to original Github repository" <|
                \() ->
                    start () baseUrl
                        |> expectViewHas
                            [ id "link-inspiration"
                            , attribute (href "https://github.com/dmy/elm-realworld-example-app")
                            ]
            ]
        , describe "settings page"
            [ test "settings page has dark mode button" <|
                \() ->
                    start () (baseUrl ++ "#/settings")
                        |> expectViewHas
                            [ id "button-dark-mode" ]
            , test "clicking dark mode button removes it" <|
                \() ->
                    start () (baseUrl ++ "#/settings")
                        |> clickButton "Dark Mode"
                        |> expectViewHasNot
                            [ id "button-dark-mode" ]
            , test "clicking dark mode button adds a light mode button" <|
                \() ->
                    start () (baseUrl ++ "#/settings")
                        |> clickButton "Dark Mode"
                        |> expectViewHas
                            [ id "button-light-mode" ]
            ]
        ]


start : () -> String -> ProgramTest FrontendModel FrontendMsg (Cmd FrontendMsg)
start flags initialUrl =
    ProgramTest.createApplication
        { init =
            \_ url _ ->
                Frontend.init Session.init url Nothing
                    |> Frontend.perform FrontendIgnored
        , view = Frontend.view
        , update =
            \msg model ->
                Frontend.update msg model
                    |> Frontend.perform FrontendIgnored
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        }
        |> ProgramTest.withBaseUrl initialUrl
        |> ProgramTest.start flags


testNavigationLink : String -> Test
testNavigationLink link =
    test ("link to \"" ++ link ++ "\" page in navigation bar") <|
        \() ->
            start () baseUrl
                |> expectViewHas
                    [ id ("link-" ++ link)
                    , attribute (href ("#/" ++ link))
                    ]
