module Page.Home exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Env exposing (Env)
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
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
            , p [ style "margin-top" "1em" ]
                [ text ("The time is " ++ formatTime (Env.timeZone env) (Env.time env)) ]
            ]
    }



-- PRIVATE HELPERS


formatTime : Time.Zone -> Time.Posix -> String
formatTime zone posix =
    let
        element : (Time.Zone -> Time.Posix -> Int) -> String
        element e =
            String.padLeft 2 '0' <| String.fromInt <| e zone posix
    in
    element Time.toHour ++ ":" ++ element Time.toMinute
