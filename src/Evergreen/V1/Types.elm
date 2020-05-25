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
    , state : AppState.AppState
    , page : Page.Page
    }


type alias BackendModel =
    { sessions : (Dict.Dict Lamdera.SessionId Session.Session)
    }


type FrontendMsg
    = FrontendIgnored String
    | UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTimeZone Time.Zone
    | GotPageMsg Page.PageMsg


type ToBackend
    = RequestSession
    | SaveCounter Int
    | SaveMode Session.Mode


type BackendMsg
    = BackendIgnored String


type ToFrontend
    = GotSession Session.Session