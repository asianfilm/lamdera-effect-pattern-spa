module Page.Settings exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Session exposing (Mode(..), Session(..), getMode)
import ViewHelpers exposing (viewButton)



-- MODEL


type alias Model =
    {}


init : Session -> ( Model, Effect Msg )
init _ =
    ( {}, FXNone )



-- UPDATE


type Msg
    = SetMode Mode



--| SetDarkMode


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SetMode mode ->
            ( model, FXSetMode mode )



-- VIEW


view : Session -> Model -> { title : String, content : Html Msg }
view session _ =
    { title = "Settings"
    , content =
        div []
            [ text "SETTINGS"
            , p [ style "margin-top" "1em" ]
                [ case getMode session of
                    LightMode ->
                        viewButton session "Dark Mode" (SetMode DarkMode)

                    DarkMode ->
                        viewButton session "Light Mode" (SetMode LightMode)
                ]
            ]
    }
