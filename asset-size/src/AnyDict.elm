module AnyDict exposing (main)

import Any.Dict
import Html

dict = Any.Dict.makeInterface {toComparable = identity, fromComparable = identity}

x : List (Html.Html msg)
x = dict.empty |> dict.values

main = Html.div [] x