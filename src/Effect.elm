module Effect exposing (Effect(..), mapEffect)

import Route exposing (Route)
import Session exposing (Mode)
import Time
import Url exposing (Url)


type Effect msg
    = FXNone
    | FXBatch (List (Effect msg))
      -- Navigation
    | FXReplaceUrl Route
    | FXPushUrl Url
    | FXLoadUrl String
      -- Session
    | FXRequestSession
    | FXUpdateSessionCounter Int
    | FXUpdateSessionMode Mode
      -- Misc
    | FXGetTimeZone (Time.Zone -> msg)
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

        FXReplaceUrl route ->
            FXReplaceUrl route

        FXPushUrl url ->
            FXPushUrl url

        FXLoadUrl href ->
            FXLoadUrl href

        FXRequestSession ->
            FXRequestSession

        FXUpdateSessionCounter i ->
            FXUpdateSessionCounter i

        FXUpdateSessionMode mode ->
            FXUpdateSessionMode mode

        FXGetTimeZone toMsg ->
            FXGetTimeZone (toMsg >> changeMsg)

        FXScrollToTop ->
            FXScrollToTop
