module Env exposing
    ( Env
    , init
    , navKey
    , timeZone
    , updateTimeZone
    )

import Browser.Navigation as Nav
import Time


type Env
    = Env
        { navKey : Nav.Key
        , timeZone : Time.Zone
        }


init : Nav.Key -> Time.Zone -> Env
init key tz =
    Env
        { navKey = key
        , timeZone = tz
        }


navKey : Env -> Nav.Key
navKey (Env env) =
    env.navKey


timeZone : Env -> Time.Zone
timeZone (Env env) =
    env.timeZone


updateTimeZone : Time.Zone -> Env -> Env
updateTimeZone newTimeZone (Env env) =
    Env { env | timeZone = newTimeZone }
