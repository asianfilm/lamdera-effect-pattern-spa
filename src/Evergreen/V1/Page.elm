module Evergreen.V1.Page exposing (..)

import Evergreen.V1.Page.Counter as PageCounter
import Evergreen.V1.Page.Home as PageHome
import Evergreen.V1.Page.Settings as PageSettings


type Page
    = BlankPage
    | NotFoundPage
    | HomePage PageHome.Model
    | CounterPage PageCounter.Model
    | SettingsPage PageSettings.Model


type PageMsg
    = GotHomeMsg PageHome.Msg
    | GotCounterMsg PageCounter.Msg
    | GotSettingsMsg PageSettings.Msg
