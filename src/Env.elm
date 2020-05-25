module Env exposing
    ( DevMode(..)
    , Env
    , devMode
    , init
    , navKey
    , timeZone
    , updateTimeZone
    )

import Browser.Navigation as Nav
import Time


type DevMode
    = Test
    | NotTest


type Env
    = Env
        { devMode : DevMode
        , navKey : Maybe Nav.Key
        , timeZone : Time.Zone
        }


init : Maybe Nav.Key -> Time.Zone -> Env
init key tz =
    Env
        { devMode =
            if key == Nothing then
                Test

            else
                NotTest
        , navKey = key
        , timeZone = tz
        }


devMode : Env -> DevMode
devMode (Env env) =
    env.devMode


navKey : Env -> Maybe Nav.Key
navKey (Env env) =
    env.navKey


timeZone : Env -> Time.Zone
timeZone (Env env) =
    env.timeZone


updateTimeZone : Time.Zone -> Env -> Env
updateTimeZone newTimeZone (Env env) =
    Env { env | timeZone = newTimeZone }
