module Env exposing
    ( Env
    , LocalTime
    , init
    , initTest
    , navKey
    , setTime
    , setTimeWithZone
    , setTimeZone
    , timeWithZone
    )

import Browser.Navigation as Nav
import Time


type Env
    = NotReady Nav.Key
    | Ready Nav.Key LocalTime
    | Testing LocalTime
    | Invalid


type alias LocalTime =
    ( Time.Posix, Time.Zone )


init : Maybe Nav.Key -> Env
init maybeKey =
    case maybeKey of
        Just key ->
            NotReady key

        _ ->
            Invalid


initTest : LocalTime -> Env
initTest lt =
    Testing lt



-- GETTERS


navKey : Env -> Maybe Nav.Key
navKey env =
    case env of
        NotReady key ->
            Just key

        Ready key _ ->
            Just key

        _ ->
            Nothing


timeWithZone : Env -> Maybe LocalTime
timeWithZone env =
    case env of
        Ready _ lt ->
            Just lt

        Testing lt ->
            Just lt

        _ ->
            Nothing



-- SETTERS


setTime : Time.Posix -> Env -> Env
setTime t env =
    case env of
        Ready key ( _, tz ) ->
            Ready key ( t, tz )

        Testing ( _, tz ) ->
            Testing ( t, tz )

        _ ->
            env


setTimeZone : Time.Zone -> Env -> Env
setTimeZone tz env =
    case env of
        Ready key ( t, _ ) ->
            Ready key ( t, tz )

        Testing ( t, _ ) ->
            Testing ( t, tz )

        _ ->
            env


setTimeWithZone : ( Maybe Int, Maybe Time.Zone ) -> Env -> Env
setTimeWithZone ( maybeTime, maybeZone ) env =
    let
        localTime =
            ( maybeTime |> Maybe.withDefault 0 |> Time.millisToPosix
            , maybeZone |> Maybe.withDefault Time.utc
            )
    in
    case env of
        NotReady key ->
            Ready key localTime

        _ ->
            env
