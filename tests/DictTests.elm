module DictTests exposing (tests)

import Any.Dict
import Basics exposing (..)
import Expect
import List
import Maybe exposing (..)
import Test exposing (..)


type Id
    = Id Int


idDict : Any.Dict.Interface Id v v2 output Int
idDict =
    Any.Dict.makeInterface
        { fromComparable = Id
        , toComparable = \(Id int) -> int
        }


type Character
    = Tom
    | Jerry
    | Spike


characterToString : Character -> String
characterToString c =
    case c of
        Tom ->
            "tom"

        Jerry ->
            "jerry"

        Spike ->
            "spike"


characterFromString : String -> Character
characterFromString s =
    case s of
        "tom" ->
            Tom

        "jerry" ->
            Jerry

        _ ->
            Spike


characterDict : Any.Dict.Interface Character v v2 output String
characterDict =
    Any.Dict.makeInterface
        { fromComparable = characterFromString
        , toComparable = characterToString
        }


animals : Any.Dict.Dict Character String String
animals =
    characterDict.fromList [ ( Tom, "cat" ), ( Jerry, "mouse" ) ]


tests : Test
tests =
    let
        buildTests =
            describe "build Tests"
                [ test "empty" <| \() -> Expect.equal (characterDict.fromList []) characterDict.empty
                , test "singleton" <| \() -> Expect.equal (characterDict.fromList [ ( Tom, "v" ) ]) (characterDict.singleton Tom "v")
                , test "insert" <| \() -> Expect.equal (characterDict.fromList [ ( Tom, "v" ) ]) (characterDict.insert Tom "v" characterDict.empty)
                , test "insert replace" <| \() -> Expect.equal (characterDict.fromList [ ( Tom, "vv" ) ]) (characterDict.insert Tom "vv" (characterDict.singleton Tom "v"))
                , test "update" <| \() -> Expect.equal (characterDict.fromList [ ( Tom, "vv" ) ]) (characterDict.update Tom (\_ -> Just "vv") (characterDict.singleton Tom "v"))
                , test "update Nothing" <| \() -> Expect.equal characterDict.empty (characterDict.update Tom (\_ -> Nothing) (characterDict.singleton Tom "v"))
                , test "remove" <| \() -> Expect.equal characterDict.empty (characterDict.remove Tom (characterDict.singleton Tom "v"))
                , test "remove not found" <| \() -> Expect.equal (characterDict.singleton Tom "v") (characterDict.remove Spike (characterDict.singleton Tom "v"))
                ]

        queryTests =
            describe "query Tests"
                [ test "member 1" <| \() -> Expect.equal True (characterDict.member Tom animals)
                , test "member 2" <| \() -> Expect.equal False (characterDict.member Spike animals)
                , test "get 1" <| \() -> Expect.equal (Just "cat") (characterDict.get Tom animals)
                , test "get 2" <| \() -> Expect.equal Nothing (characterDict.get Spike animals)
                , test "size of empty dictionary" <| \() -> Expect.equal 0 (characterDict.size characterDict.empty)
                , test "size of example dictionary" <| \() -> Expect.equal 2 (characterDict.size animals)
                ]

        combineTests =
            describe "combine Tests"
                [ test "union" <| \() -> Expect.equal animals (characterDict.union (characterDict.singleton Jerry "mouse") (characterDict.singleton Tom "cat"))
                , test "union collison" <| \() -> Expect.equal (characterDict.singleton Tom "cat") (characterDict.union (characterDict.singleton Tom "cat") (characterDict.singleton Tom "mouse"))
                , test "intersect" <| \() -> Expect.equal (characterDict.singleton Tom "cat") (characterDict.intersect animals (characterDict.singleton Tom "cat"))
                , test "diff" <| \() -> Expect.equal (characterDict.singleton Jerry "mouse") (characterDict.diff animals (characterDict.singleton Tom "cat"))
                ]

        transformTests =
            describe "transform Tests"
                [ test "filter" <| \() -> Expect.equal (characterDict.singleton Tom "cat") (characterDict.filter (\k _ -> k == Tom) animals)
                , test "partition" <| \() -> Expect.equal ( characterDict.singleton Tom "cat", characterDict.singleton Jerry "mouse" ) (characterDict.partition (\k _ -> k == Tom) animals)
                ]

        mergeTests =
            let
                insertBoth key leftVal rightVal dict_ =
                    idDict.insert key (leftVal ++ rightVal) dict_

                s1 =
                    idDict.empty |> idDict.insert (Id 1) [ 1 ]

                s2 =
                    idDict.empty |> idDict.insert (Id 2) [ 2 ]

                s23 =
                    idDict.empty |> idDict.insert (Id 2) [ 3 ]

                b1 =
                    List.map (\i -> ( Id i, [ i ] )) (List.range 1 10) |> idDict.fromList

                b2 =
                    List.map (\i -> ( Id i, [ i ] )) (List.range 5 15) |> idDict.fromList

                bExpected =
                    [ ( 1, [ 1 ] )
                    , ( 2, [ 2 ] )
                    , ( 3, [ 3 ] )
                    , ( 4, [ 4 ] )
                    , ( 5, [ 5, 5 ] )
                    , ( 6, [ 6, 6 ] )
                    , ( 7, [ 7, 7 ] )
                    , ( 8, [ 8, 8 ] )
                    , ( 9, [ 9, 9 ] )
                    , ( 10, [ 10, 10 ] )
                    , ( 11, [ 11 ] )
                    , ( 12, [ 12 ] )
                    , ( 13, [ 13 ] )
                    , ( 14, [ 14 ] )
                    , ( 15, [ 15 ] )
                    ]
                        |> List.map (Tuple.mapFirst Id)
            in
            describe "merge Tests"
                [ test "merge empties" <|
                    \() ->
                        Expect.equal idDict.empty
                            (idDict.merge idDict.insert insertBoth idDict.insert idDict.empty idDict.empty idDict.empty)
                , test "merge singletons in order" <|
                    \() ->
                        Expect.equal [ ( Id 1, [ 1 ] ), ( Id 2, [ 2 ] ) ]
                            (idDict.merge idDict.insert insertBoth idDict.insert s1 s2 idDict.empty |> idDict.toList)
                , test "merge singletons out of order" <|
                    \() ->
                        Expect.equal [ ( Id 1, [ 1 ] ), ( Id 2, [ 2 ] ) ]
                            (idDict.merge idDict.insert insertBoth idDict.insert s2 s1 idDict.empty |> idDict.toList)
                , test "merge with duplicate key" <|
                    \() ->
                        Expect.equal [ ( Id 2, [ 2, 3 ] ) ]
                            (idDict.merge idDict.insert insertBoth idDict.insert s2 s23 idDict.empty |> idDict.toList)
                , test "partially overlapping" <|
                    \() ->
                        Expect.equal bExpected
                            (idDict.merge idDict.insert insertBoth idDict.insert b1 b2 idDict.empty |> idDict.toList)
                ]
    in
    describe "Dict Tests"
        [ buildTests
        , queryTests
        , combineTests
        , transformTests
        , mergeTests
        ]
