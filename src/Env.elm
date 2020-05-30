module Env exposing
    ( Env
    , LocalTime
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
    | Testing (Maybe LocalTime)


type alias LocalTime =
    ( Time.Posix, Time.Zone )


init : Maybe Nav.Key -> Maybe LocalTime -> Env
init maybeKey maybeLocalTime =
    case ( maybeKey, maybeLocalTime ) of
        ( Just key, _ ) ->
            DevOrProd Nothing key

        ( Nothing, Nothing ) ->
            Testing Nothing

        ( _, lt ) ->
            Testing lt



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
            lt

        DevOrProd lt _ ->
            lt



-- SETTERS


setTime : Time.Posix -> Env -> Env
setTime t env =
    case env of
        Testing (Just ( _, tz )) ->
            Testing (Just ( t, tz ))

        Testing Nothing ->
            Testing Nothing

        DevOrProd (Just ( _, tz )) key ->
            DevOrProd (Just ( t, tz )) key

        DevOrProd Nothing key ->
            DevOrProd Nothing key


setTimeZone : Time.Zone -> Env -> Env
setTimeZone tz env =
    case env of
        Testing (Just ( t, _ )) ->
            Testing (Just ( t, tz ))

        Testing Nothing ->
            Testing Nothing

        DevOrProd (Just ( t, _ )) key ->
            DevOrProd (Just ( t, tz )) key

        DevOrProd Nothing key ->
            DevOrProd Nothing key


setTimeWithZone : LocalTime -> Env -> Env
setTimeWithZone lt env =
    case env of
        Testing _ ->
            Testing (Just lt)

        DevOrProd _ key ->
            DevOrProd (Just lt) key
