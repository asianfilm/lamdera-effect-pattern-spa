module Evergreen.V2.Page exposing (..)

import Evergreen.V2.Page.Counter as PageCounter
import Evergreen.V2.Page.Home as PageHome
import Evergreen.V2.Page.Settings as PageSettings


type Page
    = Blank
    | NotFound
    | Home PageHome.Model
    | Counter PageCounter.Model
    | Settings PageSettings.Model


type NavBarMsg
    = Login
    | Logout


type PageMsg
    = HomeMsg PageHome.Msg
    | CounterMsg PageCounter.Msg
    | SettingsMsg PageSettings.Msg
    | NavBarMsg NavBarMsg
