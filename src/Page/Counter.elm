module Page.Counter exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Session exposing (Session, getCounter)
import ViewHelpers exposing (viewButton)



-- MODEL


type alias Model =
    Int


init : Session -> ( Model, Effect Msg )
init _ =
    ( 0, FXNone )



-- UPDATE


type Msg
    = Decrement
    | Increment
    | DecrementGlobal
    | IncrementGlobal


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Decrement ->
            ( model - 1, FXNone )

        Increment ->
            ( model + 1, FXNone )

        DecrementGlobal ->
            ( model, FXDecrementSharedCounter )

        IncrementGlobal ->
            ( model, FXIncrementSharedCounter )



-- VIEW


view : Session -> Model -> { title : String, content : Html Msg }
view session model =
    { title = "Counter"
    , content =
        div []
            [ viewCounter session "Page State Counter" model ( Decrement, Increment )
            , viewCounter session "Local State Counter" (getCounter session) ( DecrementGlobal, IncrementGlobal )
            ]
    }


viewCounter : Session -> String -> Int -> ( msg, msg ) -> Html msg
viewCounter session label value ( msgDec, msgInc ) =
    div
        [ style "margin-bottom" "3em" ]
        [ text (String.toUpper label)
        , p [ style "margin-top" "1em" ]
            [ viewButton session "-" msgDec
            , viewButton session "+" msgInc
            , text (" " ++ String.fromInt value ++ " ")
            ]
        ]
