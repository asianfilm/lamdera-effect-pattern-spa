module Evergreen.V1.Session exposing (..)

type Mode
    = LightMode
    | DarkMode


type alias State = 
    { counter : Int
    , mode : Mode
    }


type alias Cred = 
    { name : String
    }


type Session
    = Guest State
    | Authenticated State Cred