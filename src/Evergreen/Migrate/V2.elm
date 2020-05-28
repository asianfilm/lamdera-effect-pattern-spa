module Evergreen.Migrate.V2 exposing (..)

import Evergreen.V1.AppState as OldAppState
import Evergreen.V1.Env as OldEnv
import Evergreen.V1.Page as OldPage
import Evergreen.V1.Session as OldSession
import Evergreen.V1.Types as Old
import Evergreen.V2.AppState as NewAppState
import Evergreen.V2.Env as NewEnv
import Evergreen.V2.Page as NewPage
import Evergreen.V2.Session as NewSession
import Types as New
import Lamdera.Migrations exposing (..)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    let
        env =
            case old.env of
                OldEnv.DevOrProd t tz key ->
                    NewEnv.DevOrProd (NewEnv.CommonValues t tz) key

                OldEnv.Testing t tz ->
                    NewEnv.Testing (NewEnv.CommonValues t tz)

        page =
            case old.page of
                OldPage.BlankPage ->
                    NewPage.Blank

                OldPage.NotFoundPage ->
                    NewPage.NotFound

                OldPage.HomePage model ->
                    NewPage.Home model

                OldPage.CounterPage model ->
                    NewPage.Counter model

                OldPage.SettingsPage OldSession.DarkMode ->
                    NewPage.Settings NewSession.DarkMode

                OldPage.SettingsPage OldSession.LightMode ->
                    NewPage.Settings NewSession.LightMode

        state =
            case old.state of
                OldAppState.NotReady url ->
                    NewAppState.NotReady url

                OldAppState.Ready session ->
                    case session of
                        OldSession.Guest state ->
                            case state of
                                _ ->
                                    NewAppState.Ready (NewSession.Guest (NewSession.State 0 NewSession.LightMode))

                        OldSession.Authenticated state cred ->
                            case state of
                                _ ->
                                    NewAppState.Ready (NewSession.Authenticated (NewSession.State 0 NewSession.LightMode) (NewSession.Cred cred.name))
    in
    ModelMigrated ( New.FrontendModel env page state, Cmd.none )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel _ =
    ModelUnchanged


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg _ =
    MsgOldValueIgnored


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend _ =
    MsgOldValueIgnored


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg _ =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend _ =
    MsgUnchanged
