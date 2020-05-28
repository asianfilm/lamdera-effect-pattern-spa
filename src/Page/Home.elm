module Page.Home exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Env exposing (Env)
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Session exposing (Session)
import View.Helpers exposing (formatTime)



-- MODEL


type alias Model =
    {}


init : Session -> ( Model, Effect Msg )
init _ =
    ( {}, FXNone )



-- UPDATE


type Msg
    = NoOp



--| SetDarkMode


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
