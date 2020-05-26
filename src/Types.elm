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
    { sessions : Dict SessionId ( Int, Session )
    , time : Int
    }


type alias FrontendModel =
    { env : Env
    , page : Page
    , state : AppState
    }



-- MESSAGES


type FrontendMsg
    = Ignored String
      --
    | UrlClicked UrlRequest
    | UrlChanged Url
      --
    | GotTimeZone Time.Zone
    | GotPageMsg PageMsg
      --
    | Tick Time.Posix


type ToFrontend
    = B2FSession Session


type BackendMsg
    = BackendIgnored String
    | GarbageCollect Time.Posix


type ToBackend
    = F2BSessionRQ
    | F2BSaveCounter Int
    | F2BSaveMode Mode
