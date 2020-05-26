module BackendTest exposing (suite)

import Backend exposing (BackendEffect(..))
import Dict
import Expect exposing (Expectation)
import Secrets exposing (getSessionKey)
import Session exposing (Mode(..), Session)
import Test exposing (..)
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..))


getModel : ( a, b ) -> a
getModel =
    Tuple.first


getFX : ( a, b ) -> b
getFX =
    Tuple.second


suite : Test
suite =
    describe "Backend"
        [ test "on initialization, the sessions dictionary is empty" <|
            \() ->
                Backend.init
                    |> getModel
                    |> Expect.equal { sessions = Dict.empty }
        , test "request for saved session on a new backend returns LightMode" <|
            \() ->
                Backend.init
                    |> getModel
                    |> Backend.updateFromFrontend "sid" "cid" F2BSessionRQ
                    |> getFX
                    |> Expect.equal (FXSendSession "cid" Session.init)
        , test "after changing preferences, an updated session is sent to the frontend" <|
            \() ->
                Backend.init
                    |> getModel
                    |> Backend.updateFromFrontend "sid" "cid" F2BSessionRQ
                    |> getModel
                    |> Backend.updateFromFrontend "sid" "cid" (F2BSaveMode DarkMode)
                    |> getFX
                    |> Expect.equal (FXSendSession "cid" (Session.init |> Session.setMode getSessionKey DarkMode))
        ]
