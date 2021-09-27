module Core exposing (main)

import Dict
import Html
import Set


x =
    Dict.empty |> Dict.values


y =
    Set.empty |> Set.toList |> List.map (\_ -> Html.div [] [])


main =
    Html.div x y
