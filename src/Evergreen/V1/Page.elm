module Evergreen.V1.Page exposing (..)

import Evergreen.V1.Page.Counter as Page.Counter
import Evergreen.V1.Page.Settings as Page.Settings


type Page
    = BlankPage
    | NotFoundPage
    | HomePage
    | CounterPage Page.Counter.Model
    | SettingsPage Page.Settings.Model


type PageMsg
    = GotCounterMsg Page.Counter.Msg
    | GotSettingsMsg Page.Settings.Msg