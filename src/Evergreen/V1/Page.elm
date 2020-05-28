module Evergreen.V1.Page exposing (..)

import Evergreen.V1.Page.Counter as Page.Counter
import Evergreen.V1.Page.Home as Page.Home
import Evergreen.V1.Page.Settings as Page.Settings


type Page
    = Blank
    | NotFound
    | Home Page.Home.Model
    | Counter Page.Counter.Model
    | Settings Page.Settings.Model


type NavBarMsg
    = Login
    | Logout


type PageMsg
    = HomeMsg Page.Home.Msg
    | CounterMsg Page.Counter.Msg
    | SettingsMsg Page.Settings.Msg
    | NavBarMsg NavBarMsg