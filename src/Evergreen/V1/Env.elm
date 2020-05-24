module Evergreen.V1.Env exposing (..)

import Browser.Navigation
import Time


type Env
    = Env 
    { navKey : Browser.Navigation.Key
    , timeZone : Time.Zone
    }