module Session exposing (Mode(..), Session, getCounter, getMode, getName, init, setCounter, setMode, signIn)

import Secrets exposing (SessionKey)



-- TYPES


type Session
    = Guest State
    | Authenticated State Cred


type alias State =
    { counter : Int
    , mode : Mode
    }


type Mode
    = LightMode
    | DarkMode


type alias Cred =
    { name : String
    }


init : Session
init =
    Guest { counter = 0, mode = LightMode }



-- COUNTER


getCounter : Session -> Int
getCounter s =
    case s of
        Guest state ->
            state.counter

        Authenticated state _ ->
            state.counter


setCounter : SessionKey -> Int -> Session -> Session
setCounter _ i s =
    case s of
        Guest ({ counter } as state) ->
            Guest { state | counter = counter + i }

        Authenticated ({ counter } as state) cred ->
            Authenticated { state | counter = counter + i } cred



-- MODE


getMode : Session -> Mode
getMode s =
    case s of
        Guest state ->
            state.mode

        Authenticated state _ ->
            state.mode


setMode : SessionKey -> Mode -> Session -> Session
setMode _ m s =
    case s of
        Guest state ->
            Guest { state | mode = m }

        Authenticated state cred ->
            Authenticated { state | mode = m } cred



-- NAME


getName : Session -> Maybe String
getName s =
    case s of
        Guest _ ->
            Nothing

        Authenticated _ cred ->
            Just cred.name


signIn : SessionKey -> String -> Session -> Session
signIn _ name session =
    case session of
        Guest state ->
            Authenticated state { name = name }

        Authenticated _ _ ->
            session
