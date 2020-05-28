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
    = DevOrProd CommonValues Nav.Key
    | Testing CommonValues


type alias CommonValues =
    { time : Int
    , zone : Time.Zone
    }


init : Maybe Nav.Key -> Env
init maybeKey =
    let
        cv =
            CommonValues 0 Time.utc
    in
    case maybeKey of
        Nothing ->
            Testing cv

        Just key ->
            DevOrProd cv key



-- GETTERS


navKey : Env -> Maybe Nav.Key
navKey env =
    case env of
        Testing _ ->
            Nothing

        DevOrProd _ key ->
            Just key


time : Env -> Time.Posix
time env =
    case env of
        Testing cv ->
            Time.millisToPosix cv.time

        DevOrProd cv _ ->
            Time.millisToPosix cv.time


timeZone : Env -> Time.Zone
timeZone env =
    case env of
        Testing cv ->
            cv.zone

        DevOrProd cv _ ->
            cv.zone



-- SETTERS


setTime : Time.Posix -> Env -> Env
setTime t env =
    case env of
        Testing cv ->
            Testing { cv | time = Time.posixToMillis t }

        DevOrProd cv key ->
            DevOrProd { cv | time = Time.posixToMillis t } key


setTimeZone : Time.Zone -> Env -> Env
setTimeZone tz env =
    case env of
        Testing cv ->
            Testing { cv | zone = tz }

        DevOrProd cv key ->
            DevOrProd { cv | zone = tz } key
