module Evergreen.V1.Env exposing (..)

import Browser.Navigation
import Time


type Env
    = DevOrProd Int Time.Zone Browser.Navigation.Key
    | Testing Int Time.Zone