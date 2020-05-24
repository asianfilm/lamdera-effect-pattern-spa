module Page.Home exposing (view)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)



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
