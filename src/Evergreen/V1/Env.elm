module Evergreen.V1.Env exposing (..)

import Browser.Navigation
import Time


type alias CommonValues = 
    { time : Int
    , zone : Time.Zone
    }


type Env
    = DevOrProd CommonValues Browser.Navigation.Key
    | Testing CommonValues