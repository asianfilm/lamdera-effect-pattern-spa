module Evergreen.V1.Page.Settings exposing (..)

import Evergreen.V1.Session as Session


type alias Model = Session.Mode


type Msg
    = SetMode Session.Mode