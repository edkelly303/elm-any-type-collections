module Any exposing (main)

import Any.Dict
import Any.Set
import Html


dict =
    Any.Dict.makeInterface { toComparable = identity, fromComparable = identity }


set =
    Any.Set.makeInterface { toComparable = identity, fromComparable = identity }


x =
    dict.empty |> dict.values


y =
    set.empty |> set.toList |> List.map (\_ -> Html.div [] [])


main =
    Html.div x y
