module Page.Home exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Session exposing (Session)



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
update msg model =
    ( model, FXNone )



-- VIEW


view : { title : String, content : Html msg }
view =
    { title = "Home"
    , content =
        div []
            [ text "HOME"
            , p [ style "margin-top" "1em" ]
                [ text "Welcome to our SPA" ]
            ]
    }
