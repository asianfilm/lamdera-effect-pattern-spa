module Evergreen.V1.AppState exposing (..)

import Evergreen.V1.Session as Session
import Url


type AppState
    = NotReady Url.Url
    | Ready Session.Session