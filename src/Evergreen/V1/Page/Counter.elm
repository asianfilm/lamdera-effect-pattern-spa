module Evergreen.V1.Page.Counter exposing (..)

type alias Model = Int


type Msg
    = Decrement
    | Increment
    | DecrementGlobal
    | IncrementGlobal