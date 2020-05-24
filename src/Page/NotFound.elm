module Page.NotFound exposing (view)

import Html exposing (Html, text)



-- VIEW


view : { title : String, content : Html msg }
view =
    { title = "404"
    , content = text "Not sure how you got here..."
    }
