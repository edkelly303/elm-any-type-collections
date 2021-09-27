module CoreDict exposing (main)

import Html
import Dict

x : List (Html.Html msg)
x = Dict.empty |> Dict.values

main = Html.div [] x