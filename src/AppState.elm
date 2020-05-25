module AppState exposing (AppState(..), init)

import Session exposing (Session)
import Url exposing (Url)


type AppState
    = NotReady Url
    | Ready Session


init : Url -> AppState
init url =
    NotReady url
