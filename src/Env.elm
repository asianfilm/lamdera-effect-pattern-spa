module Env exposing
    ( Env
    , init
    , navKey
    , setTime
    , setTimeWithZone
    , setTimeZone
    , timeWithZone
    )

import Browser.Navigation as Nav
import Time



-- MODEL


type Env
    = DevOrProd (Maybe LocalTime) Nav.Key
    | Testing LocalTime


type alias LocalTime =
    ( Time.Posix, Time.Zone )


init : Maybe Nav.Key -> Maybe Time.Posix -> Env
init maybeKey maybeTime =
    case ( maybeKey, maybeTime ) of
        ( Just key, _ ) ->
            DevOrProd Nothing key

        ( _, Just t ) ->
            Testing ( t, Time.utc )

        ( Nothing, Nothing ) ->
            Testing ( Time.millisToPosix 0, Time.utc )



-- GETTERS


navKey : Env -> Maybe Nav.Key
navKey env =
    case env of
        Testing _ ->
            Nothing

        DevOrProd _ key ->
            Just key


timeWithZone : Env -> Maybe ( Time.Posix, Time.Zone )
timeWithZone env =
    case env of
        Testing lt ->
            Just lt

        DevOrProd lt _ ->
            lt



-- SETTERS


setTime : Time.Posix -> Env -> Env
setTime t env =
    case env of
        Testing ( _, tz ) ->
            Testing ( t, tz )

        DevOrProd (Just ( _, tz )) key ->
            DevOrProd (Just ( t, tz )) key

        DevOrProd Nothing key ->
            DevOrProd Nothing key


setTimeZone : Time.Zone -> Env -> Env
setTimeZone tz env =
    case env of
        Testing ( t, _ ) ->
            Testing ( t, tz )

        DevOrProd (Just ( t, _ )) key ->
            DevOrProd (Just ( t, tz )) key

        DevOrProd Nothing key ->
            DevOrProd Nothing key


setTimeWithZone : LocalTime -> Env -> Env
setTimeWithZone lt env =
    case env of
        Testing _ ->
            Testing lt

        DevOrProd _ key ->
            DevOrProd (Just lt) key
