module Evergreen.V2.Env exposing (..)

import Browser.Navigation
import Time


type alias CommonValues = 
    { time : Int
    , zone : Time.Zone
    }


type Env
    = DevOrProd CommonValues Browser.Navigation.Key
    | Testing CommonValues