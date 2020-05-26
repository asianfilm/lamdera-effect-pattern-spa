module Env exposing
    ( Env
    , init
    , navKey
    , setTime
    , setTimeZone
    , time
    , timeZone
    )

import Browser.Navigation as Nav
import Time



-- MODEL


type Env
    = DevOrProd Int Time.Zone Nav.Key
    | Testing Int Time.Zone


init : Maybe Nav.Key -> Env
init maybeKey =
    case maybeKey of
        Nothing ->
            Testing 0 Time.utc

        Just key ->
            DevOrProd 0 Time.utc key



-- GETTERS


navKey : Env -> Maybe Nav.Key
navKey env =
    case env of
        Testing _ _ ->
            Nothing

        DevOrProd _ _ key ->
            Just key


time : Env -> Time.Posix
time env =
    case env of
        Testing t _ ->
            Time.millisToPosix t

        DevOrProd t _ _ ->
            Time.millisToPosix t


timeZone : Env -> Time.Zone
timeZone env =
    case env of
        Testing _ tz ->
            tz

        DevOrProd _ tz _ ->
            tz



-- SETTERS


setTime : Time.Posix -> Env -> Env
setTime t env =
    case env of
        Testing _ tz ->
            Testing (Time.posixToMillis t) tz

        DevOrProd _ tz key ->
            DevOrProd (Time.posixToMillis t) tz key


setTimeZone : Time.Zone -> Env -> Env
setTimeZone tz env =
    case env of
        Testing t _ ->
            Testing t tz

        DevOrProd t _ key ->
            DevOrProd t tz key
