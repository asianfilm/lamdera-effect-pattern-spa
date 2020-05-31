module Page.Counter exposing (Model, Msg, init, update, view)

import Effect exposing (Effect(..))
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Session exposing (Session, getCounter, getMode)
import View.Button as Button


type alias Model =
    ( Int, Int )


init : Session -> ( Model, Effect Msg )
init session =
    ( ( 0, getCounter session ), FXNone )



-- UPDATE


type Msg
    = UpdatePageCounter Int
    | UpdateSessionCounter Int


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UpdatePageCounter i ->
            ( Tuple.mapFirst ((+) i) model, FXNone )

        UpdateSessionCounter i ->
            ( Tuple.mapSecond ((+) i) model, FXSaveCounter i )



-- VIEW


view : Session -> Model -> { title : String, content : Html Msg }
view session model =
    { title = "Counter"
    , content =
        div []
            [ viewCounterGroup session "Page State Counter" (Tuple.first model) UpdatePageCounter
            , viewCounterGroup session "Session State Counter" (getCounter session) UpdateSessionCounter
            ]
    }


viewCounterGroup : Session -> String -> Int -> (Int -> Msg) -> Html Msg
viewCounterGroup session label value msg =
    div
        [ style "margin-bottom" "3em"
        ]
        [ text (String.toUpper label)
        , p [ style "margin-top" "1em" ]
            [ viewCounter session "-" (msg -1)
            , viewCounter session "+" (msg 1)
            , text (" " ++ String.fromInt value ++ " ")
            ]
        ]


viewCounter : Session -> String -> Msg -> Html Msg
viewCounter session label msg =
    Button.button
        |> Button.onClick msg
        |> Button.withMode (getMode session)
        |> Button.withLabel label
        |> Button.view
