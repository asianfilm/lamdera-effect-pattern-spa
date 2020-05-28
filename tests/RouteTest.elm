module RouteTest exposing (suite)

import Expect exposing (Expectation)
import Route exposing (Route)
import Test exposing (..)
import Url exposing (Url)


suite : Test
suite =
    describe "Route.fromUrl"
        [ testUrl "" Route.Home
        , testUrl "counter" Route.Counter
        , testUrl "settings" Route.Settings
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
