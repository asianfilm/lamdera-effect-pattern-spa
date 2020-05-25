module Evergreen.V1.Env exposing (..)

import Browser.Navigation
import Time


type DevMode
    = Test
    | NotTest


type Env
    = Env 
    { devMode : DevMode
    , navKey : (Maybe Browser.Navigation.Key)
    , timeZone : Time.Zone
    }