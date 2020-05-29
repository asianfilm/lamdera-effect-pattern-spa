module Effect exposing (Effect(..), mapEffect)

import Route exposing (Route)
import Session exposing (Mode(..))
import Time
import Url exposing (Url)


type Effect msg
    = FXNone
    | FXBatch (List (Effect msg))
      -- Requests
    | FXStateRQ
    | FXTimeNowRQ (Time.Posix -> msg)
    | FXTimeZoneRQ (Time.Zone -> msg)
      -- Routing
    | FXUrlLoad String
    | FXUrlPush Url
    | FXUrlReplace Route
      -- Session
    | FXLogin
    | FXLogout
    | FXSaveCounter Int
    | FXSaveMode Mode
      -- UI
    | FXScrollToTop


{-| Transform the messages produced by an effect.
-}
mapEffect : (a -> msg) -> Effect a -> Effect msg
mapEffect changeMsg effect =
    case effect of
        FXNone ->
            FXNone

        FXBatch effects ->
            FXBatch (List.map (mapEffect changeMsg) effects)

        -- Requests
        FXStateRQ ->
            FXStateRQ

        -- Routing
        FXUrlLoad href ->
            FXUrlLoad href

        FXUrlPush url ->
            FXUrlPush url

        FXUrlReplace route ->
            FXUrlReplace route

        FXTimeNowRQ toMsg ->
            FXTimeNowRQ (toMsg >> changeMsg)

        FXTimeZoneRQ toMsg ->
            FXTimeZoneRQ (toMsg >> changeMsg)

        -- Session
        FXLogin ->
            FXLogin

        FXLogout ->
            FXLogout

        FXSaveCounter i ->
            FXSaveCounter i

        FXSaveMode mode ->
            FXSaveMode mode

        -- UI
        FXScrollToTop ->
            FXScrollToTop
