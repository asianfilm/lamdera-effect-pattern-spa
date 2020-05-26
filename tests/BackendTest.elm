module BackendTest exposing (suite)

import Backend exposing (BackendEffect(..))
import Dict
import Expect exposing (Expectation)
import Secrets exposing (getSessionKey)
import Session exposing (Mode(..), Session)
import Test exposing (..)
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..))


suite : Test
suite =
    describe "Backend"
        [ test "on initialization, the sessions dictionary is empty" <|
            \() ->
                Backend.init
                    |> expectSessionStoreSize 0
        , test "sessions are only stored once" <|
            \() ->
                Backend.init
                    |> sessionRequest
                    |> saveMode DarkMode
                    |> saveMode LightMode
                    |> expectSessionStoreSize 1
        , test "request for saved session on a new backend returns the default session" <|
            \() ->
                Backend.init
                    |> sessionRequest
                    |> expectEffect (FXSendSession "cid" Session.init)
        , test "after changing preferences, an updated session is sent to the frontend" <|
            \() ->
                Backend.init
                    |> sessionRequest
                    |> saveMode DarkMode
                    |> expectEffect (FXSendSession "cid" (Session.init |> Session.setMode getSessionKey DarkMode))
        ]



-- HELPERS


expectEffect : BackendEffect BackendMsg -> ( BackendModel, BackendEffect BackendMsg ) -> Expectation
expectEffect e b =
    if e == Tuple.second b then
        Expect.pass

    else
        Expect.fail "The effect to peform does not match"


expectSessionStoreSize : Int -> ( BackendModel, BackendEffect BackendMsg ) -> Expectation
expectSessionStoreSize size b =
    if size == (b |> Tuple.first |> .sessions |> Dict.size) then
        Expect.pass

    else
        Expect.fail ("The count of sessions does not equal " ++ String.fromInt size)


saveMode mode t =
    t |> Tuple.first |> Backend.updateFromFrontend "sid" "cid" (F2BSaveMode mode)


sessionRequest t =
    t |> Tuple.first |> Backend.updateFromFrontend "sid" "cid" F2BSessionRQ
