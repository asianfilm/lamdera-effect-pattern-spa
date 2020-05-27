module Evergreen.V1.Page exposing (..)

import Evergreen.V1.Page.Counter as Page.Counter
import Evergreen.V1.Page.Home as Page.Home
import Evergreen.V1.Page.Settings as Page.Settings


type Page
    = BlankPage
    | NotFoundPage
    | HomePage Page.Home.Model
    | CounterPage Page.Counter.Model
    | SettingsPage Page.Settings.Model


type PageMsg
    = GotHomeMsg Page.Home.Msg
    | GotCounterMsg Page.Counter.Msg
    | GotSettingsMsg Page.Settings.Msg