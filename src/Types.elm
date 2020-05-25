module Types exposing (..)

import AppState exposing (AppState)
import Browser exposing (UrlRequest)
import Dict exposing (Dict)
import Env exposing (Env)
import Lamdera exposing (SessionId)
import Page exposing (Page, PageMsg)
import Session exposing (Mode(..), Session)
import Time
import Url exposing (Url)



-- MODELS


type alias BackendModel =
    { sessions : Dict SessionId Session
    }


type alias FrontendModel =
    { env : Env
    , state : AppState
    , page : Page
    }



-- MESSAGES


type FrontendMsg
    = FrontendIgnored String
      --
    | UrlClicked UrlRequest
    | UrlChanged Url
      --
    | GotTimeZone Time.Zone
    | GotPageMsg PageMsg


type ToFrontend
    = GotSession Session


type BackendMsg
    = BackendIgnored String


type ToBackend
    = RequestSession
    | SaveCounter Int
    | SaveMode Mode
