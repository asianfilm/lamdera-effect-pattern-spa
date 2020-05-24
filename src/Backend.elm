module Backend exposing (BackendEffect(..), app, init, updateFromFrontend)

import Dict
import Lamdera exposing (ClientId, SessionId)
import Secrets exposing (getSessionKey)
import Session exposing (Session(..))
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
        , subscriptions = \_ -> Sub.none
        }


type BackendEffect msg
    = FXNone
    | FXBatch (List (BackendEffect msg))
    | FXSendSession SessionId Session


init : ( BackendModel, BackendEffect BackendMsg )
init =
    ( { sessions = Dict.empty }, FXNone )



-- UPDATE


update : BackendMsg -> BackendModel -> ( BackendModel, BackendEffect BackendMsg )
update msg model =
    case msg of
        BackendIgnored _ ->
            ( model, FXNone )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, BackendEffect BackendMsg )
updateFromFrontend sid cid msg model =
    let
        session =
            case Dict.get sid model.sessions of
                Just s ->
                    s

                -- Simply return a new session because, as-of-now, "mutating" messages update sessions dictionary.
                -- May need to adapt this to explicitly update and return the model; inserting in dictionary here.
                Nothing ->
                    Session.init
    in
    case msg of
        RequestSession ->
            ( model, FXSendSession cid session )

        SaveCounter change ->
            let
                updatedSession =
                    session |> Session.setCounter getSessionKey change
            in
            ( { model | sessions = Dict.insert sid updatedSession model.sessions }
            , FXSendSession cid updatedSession
            )

        SaveMode mode ->
            let
                updatedSession =
                    session |> Session.setMode getSessionKey mode
            in
            ( { model | sessions = Dict.insert sid updatedSession model.sessions }
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
            ( model, Lamdera.sendToFrontend cid (GotSession session) )


batchEffect : (String -> msg) -> BackendEffect msg -> ( BackendModel, List (Cmd msg) ) -> ( BackendModel, List (Cmd msg) )
batchEffect ignore effect ( model, cmds ) =
    perform ignore ( model, effect )
        |> Tuple.mapSecond (\cmd -> cmd :: cmds)
