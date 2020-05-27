module Evergreen.V1.Page.Counter exposing (..)

type alias Model = (Int, Int)


type Msg
    = UpdatePageCounter Int
    | UpdateSessionCounter Int