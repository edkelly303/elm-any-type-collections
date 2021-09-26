module SetTests exposing (..)

import Any.Set
import Basics exposing (..)
import Expect
import List exposing ((::))
import Test exposing (..)


tests : Test
tests =
    describe "Set Tests"
        [ describe "empty" emptyTests
        , describe "singleton" singletonTests
        , describe "insert" insertTests
        , describe "remove" removeTests
        , describe "isEmpty" isEmptyTests
        , describe "member" memberTests
        , describe "size" sizeTests
        , describe "foldl" foldlTests
        , describe "foldr" foldrTests
        , describe "map" mapTests
        , describe "filter" filterTests
        , describe "partition" partitionTests
        , describe "union" unionTests
        , describe "intersect" intersectTests
        , describe "diff" diffTests
        , describe "toList" toListTests
        , describe "fromList" fromListTests
        ]


type Id
    = Id Int


idSet : Any.Set.Interface Id b output Int comparable2
idSet =
    Any.Set.makeInterface { fromComparable = Id, toComparable = \(Id int) -> int }



-- HELPERS


set42 : Any.Set.Set Id Int
set42 =
    idSet.singleton (Id 42)


set1To100 : Any.Set.Set Id Int
set1To100 =
    idSet.fromList (List.range 1 100 |> List.map Id)


set1To50 : Any.Set.Set Id Int
set1To50 =
    idSet.fromList (List.range 1 50 |> List.map Id)


set51To100 : Any.Set.Set Id Int
set51To100 =
    idSet.fromList (List.range 51 100 |> List.map Id)


set51To150 : Any.Set.Set Id Int
set51To150 =
    idSet.fromList (List.range 51 150 |> List.map Id)


isLessThan51 : Id -> Bool
isLessThan51 (Id n) =
    n < 51



-- TESTS


emptyTests : List Test
emptyTests =
    [ test "returns an empty set" <|
        \() -> Expect.equal 0 (idSet.size idSet.empty)
    ]


singletonTests : List Test
singletonTests =
    [ test "returns set with one element" <|
        \() -> Expect.equal 1 (idSet.size (idSet.singleton (Id 1)))
    , test "contains given element" <|
        \() -> Expect.equal True (idSet.member (Id 1) (idSet.singleton (Id 1)))
    ]


insertTests : List Test
insertTests =
    [ test "adds new element to empty set" <|
        \() -> Expect.equal set42 (idSet.insert (Id 42) idSet.empty)
    , test "adds new element to a set of 100" <|
        \() -> Expect.equal (idSet.fromList (List.range 1 101 |> List.map Id)) (idSet.insert (Id 101) set1To100)
    , test "leaves singleton set intact if it contains given element" <|
        \() -> Expect.equal set42 (idSet.insert (Id 42) set42)
    , test "leaves set of 100 intact if it contains given element" <|
        \() -> Expect.equal set1To100 (idSet.insert (Id 42) set1To100)
    ]


removeTests : List Test
removeTests =
    [ test "removes element from singleton set" <|
        \() -> Expect.equal idSet.empty (idSet.remove (Id 42) set42)
    , test "removes element from set of 100" <|
        \() -> Expect.equal (idSet.fromList (List.range 1 99 |> List.map Id)) (idSet.remove (Id 100) set1To100)
    , test "leaves singleton set intact if it doesn't contain given element" <|
        \() -> Expect.equal set42 (idSet.remove (Id -1) set42)
    , test "leaves set of 100 intact if it doesn't contain given element" <|
        \() -> Expect.equal set1To100 (idSet.remove (Id -1) set1To100)
    ]


isEmptyTests : List Test
isEmptyTests =
    [ test "returns True for empty set" <|
        \() -> Expect.equal True (idSet.isEmpty idSet.empty)
    , test "returns False for singleton set" <|
        \() -> Expect.equal False (idSet.isEmpty set42)
    , test "returns False for set of 100" <|
        \() -> Expect.equal False (idSet.isEmpty set1To100)
    ]


memberTests : List Test
memberTests =
    [ test "returns True when given element inside singleton set" <|
        \() -> Expect.equal True (idSet.member (Id 42) set42)
    , test "returns True when given element inside set of 100" <|
        \() -> Expect.equal True (idSet.member (Id 42) set1To100)
    , test "returns False for element not in singleton" <|
        \() -> Expect.equal False (idSet.member (Id -1) set42)
    , test "returns False for element not in set of 100" <|
        \() -> Expect.equal False (idSet.member (Id -1) set1To100)
    ]


sizeTests : List Test
sizeTests =
    [ test "returns 0 for empty set" <|
        \() -> Expect.equal 0 (idSet.size idSet.empty)
    , test "returns 1 for singleton set" <|
        \() -> Expect.equal 1 (idSet.size set42)
    , test "returns 100 for set of 100" <|
        \() -> Expect.equal 100 (idSet.size set1To100)
    ]


foldlTests : List Test
foldlTests =
    [ test "with insert and empty set acts as identity function" <|
        \() -> Expect.equal set1To100 (idSet.foldl idSet.insert idSet.empty set1To100)
    , test "with counter and zero acts as size function" <|
        \() -> Expect.equal 100 (idSet.foldl (\_ count -> count + 1) 0 set1To100)
    , test "folds set elements from lowest to highest" <|
        \() -> Expect.equal [ Id 3, Id 2, Id 1 ] (idSet.foldl (\n ns -> n :: ns) [] (idSet.fromList [ Id 2, Id 1, Id 3 ]))
    ]


foldrTests : List Test
foldrTests =
    [ test "with insert and empty set acts as identity function" <|
        \() -> Expect.equal set1To100 (idSet.foldr idSet.insert idSet.empty set1To100)
    , test "with counter and zero acts as size function" <|
        \() -> Expect.equal 100 (idSet.foldr (\_ count -> count + 1) 0 set1To100)
    , test "folds set elements from highest to lowest" <|
        \() -> Expect.equal [ Id 1, Id 2, Id 3 ] (idSet.foldr (\n ns -> n :: ns) [] (idSet.fromList [ Id 2, Id 1, Id 3 ]))
    ]


mapTests : List Test
mapTests =
    [ test "applies given function to singleton element" <|
        \() -> Expect.equal (idSet.singleton (Id 43)) (idSet.map (\(Id int) -> int) (\(Id int) -> Id (int + 1)) set42)
    , test "applies given function to each element" <|
        \() -> Expect.equal (idSet.fromList (List.range -100 -1 |> List.map Id)) (idSet.map (\(Id int) -> int) (\(Id int) -> Id (negate int)) set1To100)
    ]


filterTests : List Test
filterTests =
    [ test "with always True doesn't change anything" <|
        \() -> Expect.equal set1To100 (idSet.filter (always True) set1To100)
    , test "with always False returns empty set" <|
        \() -> Expect.equal idSet.empty (idSet.filter (always False) set1To100)
    , test "simple filter" <|
        \() -> Expect.equal set1To50 (idSet.filter isLessThan51 set1To100)
    ]


partitionTests : List Test
partitionTests =
    [ test "of empty set returns two empty sets" <|
        \() -> Expect.equal ( idSet.empty, idSet.empty ) (idSet.partition isLessThan51 idSet.empty)
    , test "simple partition" <|
        \() -> Expect.equal ( set1To50, set51To100 ) (idSet.partition isLessThan51 set1To100)
    ]


unionTests : List Test
unionTests =
    [ test "with empty set doesn't change anything" <|
        \() -> Expect.equal set42 (idSet.union set42 idSet.empty)
    , test "with itself doesn't change anything" <|
        \() -> Expect.equal set1To100 (idSet.union set1To100 set1To100)
    , test "with subset doesn't change anything" <|
        \() -> Expect.equal set1To100 (idSet.union set1To100 set42)
    , test "with superset returns superset" <|
        \() -> Expect.equal set1To100 (idSet.union set42 set1To100)
    , test "contains elements of both singletons" <|
        \() -> Expect.equal (idSet.insert (Id 1) set42) (idSet.union set42 (idSet.singleton (Id 1)))
    , test "consists of elements from either set" <|
        \() ->
            idSet.union set1To100 set51To150
                |> Expect.equal (idSet.fromList (List.range 1 150 |> List.map Id))
    ]


intersectTests : List Test
intersectTests =
    [ test "with empty set returns empty set" <|
        \() -> Expect.equal idSet.empty (idSet.intersect set42 idSet.empty)
    , test "with itself doesn't change anything" <|
        \() -> Expect.equal set1To100 (idSet.intersect set1To100 set1To100)
    , test "with subset returns subset" <|
        \() -> Expect.equal set42 (idSet.intersect set1To100 set42)
    , test "with superset doesn't change anything" <|
        \() -> Expect.equal set42 (idSet.intersect set42 set1To100)
    , test "returns empty set given disjunctive sets" <|
        \() -> Expect.equal idSet.empty (idSet.intersect set42 (idSet.singleton (Id 1)))
    , test "consists of common elements only" <|
        \() ->
            idSet.intersect set1To100 set51To150
                |> Expect.equal set51To100
    ]


diffTests : List Test
diffTests =
    [ test "with empty set doesn't change anything" <|
        \() -> Expect.equal set42 (idSet.diff set42 idSet.empty)
    , test "with itself returns empty set" <|
        \() -> Expect.equal idSet.empty (idSet.diff set1To100 set1To100)
    , test "with subset returns set without subset elements" <|
        \() -> Expect.equal (idSet.remove (Id 42) set1To100) (idSet.diff set1To100 set42)
    , test "with superset returns empty set" <|
        \() -> Expect.equal idSet.empty (idSet.diff set42 set1To100)
    , test "doesn't change anything given disjunctive sets" <|
        \() -> Expect.equal set42 (idSet.diff set42 (idSet.singleton (Id 1)))
    , test "only keeps values that don't appear in the second set" <|
        \() ->
            idSet.diff set1To100 set51To150
                |> Expect.equal set1To50
    ]


toListTests : List Test
toListTests =
    [ test "returns empty list for empty set" <|
        \() -> Expect.equal [] (idSet.toList idSet.empty)
    , test "returns singleton list for singleton set" <|
        \() -> Expect.equal [ Id 42 ] (idSet.toList set42)
    , test "returns sorted list of set elements" <|
        \() -> Expect.equal (List.range 1 100 |> List.map Id) (idSet.toList set1To100)
    ]


fromListTests : List Test
fromListTests =
    [ test "returns empty set for empty list" <|
        \() -> Expect.equal idSet.empty (idSet.fromList [])
    , test "returns singleton set for singleton list" <|
        \() -> Expect.equal set42 (idSet.fromList [ Id 42 ])
    , test "returns set with unique list elements" <|
        \() -> Expect.equal set1To100 (idSet.fromList (Id 1 :: (List.range 1 100 |> List.map Id)))
    ]
