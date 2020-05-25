module Evergreen.V1.Env exposing (..)

import Browser.Navigation
import Time


type Env
    = DevOrProd Time.Zone Browser.Navigation.Key
    | Testing Time.Zone