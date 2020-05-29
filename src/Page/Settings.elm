module Page.Settings exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Session exposing (Mode(..), Session(..), getMode)
import View.Button as Button



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
view _ model =
    { title = "Settings"
    , content =
        div []
            [ text "SETTINGS"
            , p [ style "margin-top" "1em" ]
                [ Button.button
                    |> Button.onClick (SetMode (reverseMode model))
                    |> Button.withMode model
                    |> Button.withLabel (labelFromMode (reverseMode model))
                    |> Button.view
                ]
            ]
    }



-- PRIVATE HELPERS


labelFromMode : Mode -> String
labelFromMode m =
    case m of
        DarkMode ->
            "Dark Mode"

        LightMode ->
            "Light Mode"


reverseMode : Mode -> Mode
reverseMode m =
    case m of
        DarkMode ->
            LightMode

        LightMode ->
            DarkMode
