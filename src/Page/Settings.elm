module Page.Settings exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Session exposing (Mode(..), Session(..), getMode)
import ViewHelpers exposing (viewButton)



-- MODEL


type alias Model =
    Mode


init : Session -> ( Model, Effect Msg )
init session =
    ( getMode session, FXNone )



-- UPDATE


type Msg
    = SetMode Mode


update : Msg -> Model -> ( Model, Effect Msg )
update msg _ =
    case msg of
        SetMode mode ->
            ( mode, FXSaveMode mode )



-- VIEW


view : Session -> Model -> { title : String, content : Html Msg }
view session model =
    { title = "Settings"
    , content =
        div []
            [ text "SETTINGS"
            , p [ style "margin-top" "1em" ]
                [ case model of
                    LightMode ->
                        viewButton session "Dark Mode" (SetMode DarkMode)

                    DarkMode ->
                        viewButton session "Light Mode" (SetMode LightMode)
                ]
            ]
    }
