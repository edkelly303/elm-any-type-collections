module Benchmarks exposing (main)

import AllDict
import Any.Dict
import AssocList
import Benchmark exposing (..)
import Benchmark.Alternative
import Benchmark.Runner.Alternative as BenchmarkRunner exposing (Program, program)
import Dict


main : Program
main =
    program suite


dict =
    Any.Dict.makeInterface
        { fromComparable = identity
        , toComparable = identity
        }


list =
    List.range 1 100 
    |> List.map (\x -> ( x, x ))


coreDict =
    Dict.fromList list


asscDict =
    AssocList.fromList list


eatcDict =
    dict.fromList list


jjanDict =
    AllDict.fromList list


updater =
    Maybe.map (\v -> 51)


rank description bs =
    Benchmark.Alternative.rank
        description
        (\f -> f ())
        bs


wrap : String -> (() -> a) -> ( String, () -> () )
wrap description fn =
    ( description
    , \() ->
        let
            _ =
                fn ()
        in
        ()
    )


core =
    wrap "elm-core"


eatc =
    wrap "edkelly303/elm-any-type-collections"


assc =
    wrap "pzp1997/assoc-list"


jjan =
    wrap "jjant/elm-dict"


suite =
    Benchmark.describe "Dict"
        [ rank "fromList"
            [ core (\() -> Dict.fromList list)
            , eatc (\() -> dict.fromList list)
            , assc (\() -> AssocList.fromList list)
            , jjan (\() -> AllDict.fromList list)
            ]
        , describe "get" get
        , describe "insert" insert
        , describe "update" update
        , describe "remove" remove
        ]


describe name fn =
    Benchmark.describe name
        [ rank "start" (fn 1)
        , rank "middle" (fn 50)
        , rank "end" (fn 100)
        ]


get key =
    [ core (\() -> Dict.get key coreDict)
    , eatc (\() -> dict.get key eatcDict)
    , assc (\() -> AssocList.get key asscDict)
    , jjan (\() -> AllDict.get key jjanDict)
    ]


insert key =
    [ core (\() -> Dict.insert key key coreDict)
    , eatc (\() -> dict.insert key key eatcDict)
    , assc (\() -> AssocList.insert key key asscDict)
    , jjan (\() -> AllDict.insert key key jjanDict)
    ]


update key =
    [ core (\() -> Dict.update key updater coreDict)
    , eatc (\() -> dict.update key updater eatcDict)
    , assc (\() -> AssocList.update key updater asscDict)
    ]


remove key =
    [ core (\() -> Dict.remove key coreDict)
    , eatc (\() -> dict.remove key eatcDict)
    , assc (\() -> AssocList.remove key asscDict)
    , jjan (\() -> AllDict.remove key jjanDict)
    ]
