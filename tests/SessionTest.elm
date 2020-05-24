module SessionTest exposing (suite)

import Expect exposing (Expectation)
import Secrets exposing (getSessionKey)
import Session exposing (Mode(..), Session)
import Test exposing (..)


sessionKey =
    getSessionKey


defaultUser : Session
defaultUser =
    Session.init


authenticatedUser : Session
authenticatedUser =
    defaultUser |> Session.signIn sessionKey "Stephen"


suite : Test
suite =
    describe "Session"
        [ test "default mode is LightMode" <|
            \() ->
                defaultUser
                    |> Session.getMode
                    |> Expect.equal LightMode
        , test "default mode can be changed" <|
            \() ->
                defaultUser
                    |> Session.setMode getSessionKey DarkMode
                    |> Session.getMode
                    |> Expect.equal DarkMode
        , test "default user has no name" <|
            \() ->
                defaultUser
                    |> Session.getName
                    |> Expect.equal Nothing
        , test "authenticated user has a name" <|
            \() ->
                authenticatedUser
                    |> Session.getName
                    |> Expect.equal (Just "Stephen")
        ]
