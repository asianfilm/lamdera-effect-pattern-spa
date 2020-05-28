module Evergreen.V2.Types exposing (..)

import Evergreen.V2.AppState as AppState
import Browser
import Dict
import Evergreen.V2.Env as Env
import Lamdera
import Evergreen.V2.Page as Page
import Evergreen.V2.Session as Session
import Time
import Url


type alias FrontendModel =
    { env : Env.Env
    , page : Page.Page
    , state : AppState.AppState
    }


type alias BackendModel =
    { sessions : (Dict.Dict Lamdera.SessionId (Int, Session.Session))
    , time : Int
    }


type FrontendMsg
    = Ignored String
    | UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTimeZone Time.Zone
    | GotPageMsg Page.PageMsg
    | Tick Time.Posix


type ToBackend
    = F2BLogin
    | F2BLogout
    | F2BSessionRQ
    | F2BSaveCounter Int
    | F2BSaveMode Session.Mode


type BackendMsg
    = BackendIgnored String
    | GarbageCollect Time.Posix


type ToFrontend
    = B2FSession Session.Session