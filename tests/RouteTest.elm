module RouteTest exposing (suite)

import Expect exposing (Expectation)
import Route exposing (Route(..))
import Test exposing (..)
import Url exposing (Url)


suite : Test
suite =
    describe "Route.fromUrl"
        [ testUrl "" RouteHome
        , testUrl "counter" RouteCounter
        , testUrl "settings" RouteSettings
        ]


testUrl : String -> Route -> Test
testUrl hash route =
    test ("Parsing hash: \"" ++ hash ++ "\"") <|
        \() ->
            fragment hash
                |> Route.fromUrl
                |> Expect.equal (Just route)


fragment : String -> Url
fragment frag =
    { protocol = Url.Http
    , host = "foo.com"
    , port_ = Nothing
    , path = "bar"
    , query = Nothing
    , fragment = Just frag
    }
