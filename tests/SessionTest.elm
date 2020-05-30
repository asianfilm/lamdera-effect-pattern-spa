module SessionTest exposing (suite)

import Expect exposing (Expectation)
import Secrets exposing (getSessionKey)
import Session exposing (Mode(..), Session)
import Test exposing (..)


suite : Test
suite =
    describe "Session"
        [ test "default mode is LightMode" <|
            \() ->
                guestUser
                    |> Session.getMode
                    |> Expect.equal LightMode
        , test "default mode can be changed" <|
            \() ->
                guestUser
                    |> Session.setMode getSessionKey DarkMode
                    |> Session.getMode
                    |> Expect.equal DarkMode
        , test "default user has no name" <|
            \() ->
                guestUser
                    |> Session.getName
                    |> Expect.equal Nothing
        , test "authenticated user has a name" <|
            \() ->
                authenticatedUser
                    |> Session.getName
                    |> Expect.equal (Just "Stephen")
        ]



-- HELPERS


guestUser : Session
guestUser =
    Session.init


authenticatedUser : Session
authenticatedUser =
    guestUser |> Session.signIn getSessionKey "Stephen"
