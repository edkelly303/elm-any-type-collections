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
    List.range 1 100 |> List.map (\x -> ( x, x ))


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
    describe "Dict"
        [ rank "fromList"
            [ core (\() -> Dict.fromList list)
            , eatc (\() -> dict.fromList list)
            , assc (\() -> AssocList.fromList list)
            , jjan (\() -> AllDict.fromList list)
            ]
        , describe "get"
            [ rank "from the start of the Dict"
                [ core (\() -> Dict.get 1 coreDict)
                , eatc (\() -> dict.get 1 eatcDict)
                , assc (\() -> AssocList.get 1 asscDict)
                , jjan (\() -> AllDict.get 1 jjanDict)
                ]
            , rank "from the middle of the Dict"
                [ core (\() -> Dict.get 50 coreDict)
                , eatc (\() -> dict.get 50 eatcDict)
                , assc (\() -> AssocList.get 50 asscDict)
                , jjan (\() -> AllDict.get 50 jjanDict)
                ]
            , rank "from the end of the Dict"
                [ core (\() -> Dict.get 100 coreDict)
                , eatc (\() -> dict.get 100 eatcDict)
                , assc (\() -> AssocList.get 100 asscDict)
                , jjan (\() -> AllDict.get 100 jjanDict)
                ]
            ]
        , describe "insert"
            [ rank "at the start of the Dict"
                [ core (\() -> Dict.insert 0 0 coreDict)
                , eatc (\() -> dict.insert 0 0 eatcDict)
                , assc (\() -> AssocList.insert 0 0 asscDict)
                , jjan (\() -> AllDict.insert 0 0 jjanDict)
                ]
            , rank "into the middle of the Dict"
                [ core (\() -> Dict.insert 50 50 coreDict)
                , eatc (\() -> dict.insert 50 50 eatcDict)
                , assc (\() -> AssocList.insert 50 50 asscDict)
                , jjan (\() -> AllDict.insert 50 50 jjanDict)
                ]
            , rank "at the end of the Dict"
                [ core (\() -> Dict.insert 101 101 coreDict)
                , eatc (\() -> dict.insert 101 101 eatcDict)
                , assc (\() -> AssocList.insert 101 101 asscDict)
                , jjan (\() -> AllDict.insert 101 101 jjanDict)
                ]
            ]
        , describe "update"
            [ rank "at the start of the Dict"
                [ core (\() -> Dict.update 1 updater coreDict)
                , eatc (\() -> dict.update 1 updater eatcDict)
                , assc (\() -> AssocList.update 1 updater asscDict)
                ]
            , rank "in the middle of the Dict"
                [ core (\() -> Dict.update 50 updater coreDict)
                , eatc (\() -> dict.update 50 updater eatcDict)
                , assc (\() -> AssocList.update 50 updater asscDict)
                ]
            , rank "at the end of the Dict"
                [ core (\() -> Dict.update 100 updater coreDict)
                , eatc (\() -> dict.update 100 updater eatcDict)
                , assc (\() -> AssocList.update 100 updater asscDict)
                ]
            ]
        , describe "remove"
            [ rank "from the start of the Dict"
                [ core (\() -> Dict.remove 1 coreDict)
                , eatc (\() -> dict.remove 1 eatcDict)
                , assc (\() -> AssocList.remove 1 asscDict)
                , jjan (\() -> AllDict.remove 1 jjanDict)
                ]
            , rank "in the middle of the Dict"
                [ core (\() -> Dict.remove 50 coreDict)
                , eatc (\() -> dict.remove 50 eatcDict)
                , assc (\() -> AssocList.remove 50 asscDict)
                , jjan (\() -> AllDict.remove 50 jjanDict)
                ]
            , rank "from the end of the Dict"
                [ core (\() -> Dict.remove 100 coreDict)
                , eatc (\() -> dict.remove 100 eatcDict)
                , assc (\() -> AssocList.remove 100 asscDict)
                , jjan (\() -> AllDict.remove 100 jjanDict)
                ]
            ]
        ]
