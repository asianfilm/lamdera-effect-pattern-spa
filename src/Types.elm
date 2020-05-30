module Types exposing (..)

import Browser exposing (UrlRequest)
import Dict exposing (Dict)
import Env exposing (Env)
import Lamdera exposing (SessionId)
import Page exposing (Page, PageMsg)
import Session exposing (Mode(..), Session)
import Time
import Url exposing (Url)


type alias BackendModel =
    { sessions : Dict SessionId ( Int, Session )
    , time : Int
    }


type alias FrontendModel =
    { env : Env
    , state : AppState
    }


type AppState
    = NotReady Url ( Maybe Int, Maybe Time.Zone )
    | Ready ( Page, Session )


type FrontendMsg
    = Ignored String
      --
    | GotTick Time.Posix
    | GotTimeZone Time.Zone
    | GotPageMsg PageMsg
      --
    | UrlClicked UrlRequest
    | UrlChanged Url


type ToFrontend
    = B2FSession Session


type BackendMsg
    = BKIgnored String
    | BKGarbageCollect Time.Posix


type ToBackend
    = F2BLogin
    | F2BLogout
    | F2BSessionRQ
    | F2BSaveCounter Int
    | F2BSaveMode Mode
