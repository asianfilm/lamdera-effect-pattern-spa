module Backend exposing (BackendEffect(..), app, init, updateFromFrontend)

import Dict
import Lamdera exposing (ClientId, SessionId)
import Secrets exposing (getSessionKey)
import Session exposing (Session(..))
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))



-- MODEL


app =
    Lamdera.backend
        { init = init |> perform BackendIgnored
        , update =
            \msg model ->
                update msg model
                    |> perform BackendIgnored
        , updateFromFrontend =
            \sid cid msg model ->
                updateFromFrontend sid cid msg model
                    |> perform BackendIgnored
        , subscriptions = subscriptions
        }


type BackendEffect msg
    = FXNone
    | FXBatch (List (BackendEffect msg))
    | FXSendSession SessionId Session
    | FXTimeNowRQ (Time.Posix -> msg)


init : ( BackendModel, BackendEffect BackendMsg )
init =
    ( { sessions = Dict.empty, time = 0 }, FXTimeNowRQ GarbageCollect )



-- SUBSCRIPTIONS


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Time.every (60 * 1000) GarbageCollect



-- UPDATE


update : BackendMsg -> BackendModel -> ( BackendModel, BackendEffect BackendMsg )
update msg model =
    case msg of
        BackendIgnored _ ->
            ( model, FXNone )

        GarbageCollect now ->
            let
                oneHour =
                    1 * 60 * 60 * 1000

                isFresh : SessionId -> ( Int, Session ) -> Bool
                isFresh _ ( sessionAge, _ ) =
                    Time.posixToMillis now < (sessionAge + oneHour)
            in
            ( { model
                | sessions = model.sessions |> Dict.filter isFresh
                , time = Time.posixToMillis now
              }
            , FXNone
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, BackendEffect BackendMsg )
updateFromFrontend sid cid msg model =
    let
        session =
            case Dict.get sid model.sessions of
                Just ( _, s ) ->
                    s

                -- Simply return a new session because, as-of-now, "mutating" messages update sessions dictionary.
                -- May need explicitly update the session dictionary to include the new session and its timestamp.
                Nothing ->
                    Session.init
    in
    case msg of
        F2BLogin ->
            let
                updatedSession =
                    session |> Session.signIn getSessionKey "Stephen"
            in
            ( { model | sessions = Dict.insert sid ( model.time, updatedSession ) model.sessions }
            , FXSendSession cid updatedSession
            )

        F2BLogout ->
            let
                updatedSession =
                    Session.init
            in
            ( { model | sessions = Dict.insert sid ( model.time, updatedSession ) model.sessions }
            , FXSendSession cid updatedSession
            )

        F2BSessionRQ ->
            ( { model | sessions = Dict.insert sid ( model.time, session ) model.sessions }
            , FXSendSession cid session
            )

        F2BSaveCounter change ->
            let
                updatedSession =
                    session |> Session.setCounter getSessionKey change
            in
            ( { model | sessions = Dict.insert sid ( model.time, updatedSession ) model.sessions }
            , FXSendSession cid updatedSession
            )

        F2BSaveMode mode ->
            let
                updatedSession =
                    session |> Session.setMode getSessionKey mode
            in
            ( { model | sessions = Dict.insert sid ( model.time, updatedSession ) model.sessions }
            , FXSendSession cid updatedSession
            )



-- EFFECTS


perform : (String -> msg) -> ( BackendModel, BackendEffect msg ) -> ( BackendModel, Cmd msg )
perform ignore ( model, effect ) =
    case effect of
        FXNone ->
            ( model, Cmd.none )

        FXBatch effects ->
            List.foldl (batchEffect ignore) ( model, [] ) effects
                |> Tuple.mapSecond Cmd.batch

        FXSendSession cid session ->
            ( model, Lamdera.sendToFrontend cid (B2FSession session) )

        FXTimeNowRQ toMsg ->
            ( model, Task.perform toMsg Time.now )


batchEffect : (String -> msg) -> BackendEffect msg -> ( BackendModel, List (Cmd msg) ) -> ( BackendModel, List (Cmd msg) )
batchEffect ignore effect ( model, cmds ) =
    perform ignore ( model, effect )
        |> Tuple.mapSecond (\cmd -> cmd :: cmds)
