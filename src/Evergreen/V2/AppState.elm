module Evergreen.V2.AppState exposing (..)

import Evergreen.V2.Session as Session
import Url


type AppState
    = NotReady Url.Url
    | Ready Session.Session