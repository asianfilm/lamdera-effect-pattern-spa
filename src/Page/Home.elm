module Page.Home exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Env exposing (Env)
import Html exposing (Html, div, p, text)
import Html.Attributes as Attr
import Session exposing (Session)
import Time



-- MODEL


type alias Model =
    {}


init : Session -> ( Model, Effect Msg )
init _ =
    ( {}, FXNone )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update _ model =
    ( model, FXNone )



-- VIEW


view : Env -> { title : String, content : Html Msg }
view env =
    { title = "Home"
    , content =
        div []
            [ text "HOME"
            , p [ Attr.id "clock", Attr.style "margin-top" "1em" ]
                [ text ("The time is " ++ formatTime (Env.timeWithZone env)) ]
            ]
    }



-- PRIVATE HELPERS


formatTime : Maybe ( Time.Posix, Time.Zone ) -> String
formatTime maybeTime =
    case maybeTime of
        Just ( time, zone ) ->
            let
                element : (Time.Zone -> Time.Posix -> Int) -> String
                element e =
                    String.padLeft 2 '0' <| String.fromInt <| e zone time
            in
            element Time.toHour ++ ":" ++ element Time.toMinute

        Nothing ->
            ""
