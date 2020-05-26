module Effect exposing (Effect(..), mapEffect)

import Route exposing (Route)
import Session exposing (Mode)
import Time
import Url exposing (Url)


type Effect msg
    = FXNone
    | FXBatch (List (Effect msg))
      -- Requests
    | FXStateRQ
    | FXTimeZoneRQ (Time.Zone -> msg)
      -- Session
    | FXSaveCounter Int
    | FXSaveMode Mode
      -- UI
    | FXScrollToTop
      -- Url
    | FXUrlLoad String
    | FXUrlPush Url
    | FXUrlReplace Route


{-| Transform the messages produced by an effect.
-}
mapEffect : (a -> msg) -> Effect a -> Effect msg
mapEffect changeMsg effect =
    case effect of
        FXNone ->
            FXNone

        FXBatch effects ->
            FXBatch (List.map (mapEffect changeMsg) effects)

        -- Session
        FXSaveCounter i ->
            FXSaveCounter i

        FXSaveMode mode ->
            FXSaveMode mode

        -- Requests
        FXStateRQ ->
            FXStateRQ

        FXTimeZoneRQ toMsg ->
            FXTimeZoneRQ (toMsg >> changeMsg)

        -- UI
        FXScrollToTop ->
            FXScrollToTop

        -- Url
        FXUrlLoad href ->
            FXUrlLoad href

        FXUrlPush url ->
            FXUrlPush url

        FXUrlReplace route ->
            FXUrlReplace route
