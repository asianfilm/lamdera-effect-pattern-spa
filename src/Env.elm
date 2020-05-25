module Env exposing
    ( Env
    , init
    , navKey
    , timeZone
    , updateTimeZone
    )

import Browser.Navigation as Nav
import Time


type Env
    = DevOrProd Time.Zone Nav.Key
    | Testing Time.Zone


init : Maybe Nav.Key -> Time.Zone -> Env
init maybeKey tz =
    case maybeKey of
        Nothing ->
            Testing tz

        Just key ->
            DevOrProd tz key


navKey : Env -> Maybe Nav.Key
navKey env =
    case env of
        Testing _ ->
            Nothing

        DevOrProd _ key ->
            Just key


timeZone : Env -> Time.Zone
timeZone env =
    case env of
        Testing tz ->
            tz

        DevOrProd tz _ ->
            tz


updateTimeZone : Time.Zone -> Env -> Env
updateTimeZone tz env =
    case env of
        Testing _ ->
            Testing tz

        DevOrProd _ key ->
            DevOrProd tz key
