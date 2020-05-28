module Evergreen.V2.Page.Settings exposing (..)

import Evergreen.V2.Session as Session


type alias Model = Session.Mode


type Msg
    = SetMode Session.Mode