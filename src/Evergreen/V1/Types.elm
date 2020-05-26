module Evergreen.V1.Types exposing (..)

import Evergreen.V1.AppState as AppState
import Browser
import Dict
import Evergreen.V1.Env as Env
import Lamdera
import Evergreen.V1.Page as Page
import Evergreen.V1.Session as Session
import Time
import Url


type alias FrontendModel =
    { env : Env.Env
    , page : Page.Page
    , state : AppState.AppState
    }


type alias BackendModel =
    { sessions : (Dict.Dict Lamdera.SessionId Session.Session)
    }


type FrontendMsg
    = Ignored String
    | UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTimeZone Time.Zone
    | GotPageMsg Page.PageMsg
    | Tick Time.Posix


type ToBackend
    = F2BSessionRQ
    | F2BSaveCounter Int
    | F2BSaveMode Session.Mode


type BackendMsg
    = BackendIgnored String


type ToFrontend
    = B2FSession Session.Session