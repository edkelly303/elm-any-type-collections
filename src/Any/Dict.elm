module Any.Dict exposing
    ( Dict
    , Interface
    , makeInterface
    )

{-|


# Data

@docs Dict


# Interface

@docs Interface

@docs makeInterface

-}

import Dict as CoreDict


{-| A replacement for `elm/core`'s `Dict` data structure; the difference is that
keys can be of any type, not just `comparable`.

(When I say "any" type, there's one proviso: you must be able to provide a pair
of functions that can convert your key type into a `comparable` and back
again. So this won't work with functions, but it will work with custom types.)

-}
type Dict k v comparable
    = Dict (CoreDict.Dict comparable v)


{-| An `Interface` is just a record containing functions that mirror the API of
the `elm/core` `Dict` module.

The type signature might look daunting, but in practice you can ignore it.

All you need to remember is that if you create an `Interface` called `dict`, you
can use it just like the `elm-core` `Dict` API:

    -- elm/core
    myDict =
        Dict.singleton 1 "hello"

    -- edkelly303/elm-any-type-collections
    dict =
        Any.Dict.makeInterface
            { fromComparable = identity
            , toComparable = identity
            }

    myDict =
        dict.singleton 1 "hello"

-}
type alias Interface k v v2 output comparable =
    { -- Build
      empty : Dict k v comparable
    , singleton : k -> v -> Dict k v comparable
    , insert : k -> v -> Dict k v comparable -> Dict k v comparable
    , update : k -> (Maybe v -> Maybe v) -> Dict k v comparable -> Dict k v comparable
    , remove : k -> Dict k v comparable -> Dict k v comparable

    -- Query
    , isEmpty : Dict k v comparable -> Bool
    , member : k -> Dict k v comparable -> Bool
    , get : k -> Dict k v comparable -> Maybe v
    , size : Dict k v comparable -> Int
    , keys : Dict k v comparable -> List k
    , values : Dict k v comparable -> List v
    , toList : Dict k v comparable -> List ( k, v )
    , fromList : List ( k, v ) -> Dict k v comparable

    -- Transform
    , map : (k -> v -> v2) -> Dict k v comparable -> Dict k v2 comparable
    , foldl : (k -> v -> output -> output) -> output -> Dict k v comparable -> output
    , foldr : (k -> v -> output -> output) -> output -> Dict k v comparable -> output
    , filter : (k -> v -> Bool) -> Dict k v comparable -> Dict k v comparable
    , partition : (k -> v -> Bool) -> Dict k v comparable -> ( Dict k v comparable, Dict k v comparable )

    -- Combine
    , union : Dict k v comparable -> Dict k v comparable -> Dict k v comparable
    , intersect : Dict k v comparable -> Dict k v comparable -> Dict k v comparable
    , diff : Dict k v comparable -> Dict k v comparable -> Dict k v comparable
    , merge :
        (k -> v -> output -> output)
        -> (k -> v -> v2 -> output -> output)
        -> (k -> v2 -> output -> output)
        -> Dict k v comparable
        -> Dict k v2 comparable
        -> output
        -> output
    }


{-| Use `makeInterface` to define an `Interface` for your custom `Dict`
type. You need to supply two functions:

1.  `toComparable`, which converts your key type into any `comparable` type (i.e.
    `Int`, `String`, `Float`, or a tuple containing only `comparable` types)
2.  `fromComparable`, which converts that same `comparable` type back into your
    key type.

It's a good idea to define the `Interface` as a top-level value. Once you've
defined the `Interface`, you can use it anywhere in your code without needing to
pass it explicitly to your functions.

For example, here we define the `Interface` as a top-level value called
`colourDictInterface`:

    type Colour
        = Red
        | Green
        | Blue

    colourToInt c =
        case c of
            Red ->
                0

            Green ->
                1

            Blue ->
                2

    colourFromInt i =
        case i of
            0 ->
                Red

            1 ->
                Green

            _ ->
                Blue

    colourDictInterface =
        makeInterface
            { toComparable = colourToInt
            , fromComparable = colourFromInt
            }

    myColourDict =
        colourDictInterface.fromList
            [ ( Red, "This is red!" )
            , ( Blue, "This is blue!" )
            ]

    thisIsTrue : Bool
    thisIsTrue =
        colourDictInterface.get Red myColourDict
            == Just "This is red!"

-}
makeInterface : { toComparable : k -> comparable, fromComparable : comparable -> k } -> Interface k v v2 output comparable
makeInterface { toComparable, fromComparable } =
    { -- Build
      empty = empty
    , singleton = singleton toComparable
    , insert = insert toComparable
    , update = update toComparable
    , remove = remove toComparable

    -- Query
    , isEmpty = isEmpty
    , member = member toComparable
    , get = get toComparable
    , size = size
    , keys = keys fromComparable
    , values = values
    , toList = toList fromComparable
    , fromList = fromList toComparable

    -- Transform
    , map = map fromComparable toComparable
    , foldl = foldl fromComparable
    , foldr = foldr fromComparable
    , filter = filter fromComparable
    , partition = partition fromComparable

    -- Combine
    , union = union
    , intersect = intersect
    , diff = diff
    , merge = merge fromComparable
    }


empty : Dict k v comparable
empty =
    Dict <| CoreDict.empty


singleton : (k -> comparable) -> k -> v -> Dict k v comparable
singleton toComparable k v =
    Dict <| CoreDict.singleton (toComparable k) v


insert : (k -> comparable) -> k -> v -> Dict k v comparable -> Dict k v comparable
insert toComparable k v (Dict d) =
    Dict <| CoreDict.insert (toComparable k) v d


update : (k -> comparable) -> k -> (Maybe v -> Maybe v) -> Dict k v comparable -> Dict k v comparable
update toComparable k f (Dict d) =
    Dict <| CoreDict.update (toComparable k) f d


remove : (k -> comparable) -> k -> Dict k v comparable -> Dict k v comparable
remove toComparable k (Dict d) =
    Dict <| CoreDict.remove (toComparable k) d


isEmpty : Dict k v comparable -> Bool
isEmpty (Dict d) =
    CoreDict.isEmpty d


member : (k -> comparable) -> k -> Dict k v comparable -> Bool
member toComparable k (Dict d) =
    CoreDict.member (toComparable k) d


get : (k -> comparable) -> (k -> Dict k v comparable -> Maybe v)
get toComparable k (Dict d) =
    CoreDict.get (toComparable k) d


size : Dict k v comparable -> Int
size (Dict d) =
    CoreDict.size d


keys : (comparable -> k) -> (Dict k v comparable -> List k)
keys fromComparable (Dict d) =
    CoreDict.keys d |> List.map fromComparable


values : Dict k v comparable -> List v
values (Dict d) =
    CoreDict.values d


toList : (comparable -> k) -> Dict k v comparable -> List ( k, v )
toList fromComparable (Dict d) =
    CoreDict.toList d |> List.map (Tuple.mapFirst fromComparable)


fromList : (k -> comparable) -> List ( k, v ) -> Dict k v comparable
fromList toComparable list =
    Dict <| CoreDict.fromList <| List.map (Tuple.mapFirst toComparable) list


map : (comparable -> k) -> (k -> comparable) -> (k -> v -> v2) -> Dict k v comparable -> Dict k v2 comparable
map fromComparable toComparable f d =
    foldl fromComparable
        (\k v output ->
            insert toComparable k (f k v) output
        )
        empty
        d


foldl : (comparable -> k) -> (k -> v -> output -> output) -> output -> Dict k v comparable -> output
foldl fromComparable f output (Dict d) =
    CoreDict.foldl (\k v o -> f (fromComparable k) v o) output d


foldr : (comparable -> k) -> (k -> v -> output -> output) -> output -> Dict k v comparable -> output
foldr fromComparable f output (Dict d) =
    CoreDict.foldr (\k v o -> f (fromComparable k) v o) output d


filter : (comparable -> k) -> (k -> v -> Bool) -> Dict k v comparable -> Dict k v comparable
filter fromComparable f (Dict d) =
    Dict <| CoreDict.filter (\k v -> f (fromComparable k) v) d


partition : (comparable -> k) -> (k -> v -> Bool) -> Dict k v comparable -> ( Dict k v comparable, Dict k v comparable )
partition fromComparable f (Dict d) =
    CoreDict.partition (\k v -> f (fromComparable k) v) d
        |> Tuple.mapBoth Dict Dict


union : Dict k v comparable -> Dict k v comparable -> Dict k v comparable
union (Dict d1) (Dict d2) =
    Dict <| CoreDict.union d1 d2


intersect : Dict k v comparable -> Dict k v comparable -> Dict k v comparable
intersect (Dict d1) (Dict d2) =
    Dict <| CoreDict.intersect d1 d2


diff : Dict k v comparable -> Dict k v comparable -> Dict k v comparable
diff (Dict d1) (Dict d2) =
    Dict <| CoreDict.diff d1 d2


merge :
    (comparable -> k)
    -> (k -> v -> output -> output)
    -> (k -> v -> v2 -> output -> output)
    -> (k -> v2 -> output -> output)
    -> Dict k v comparable
    -> Dict k v2 comparable
    -> output
    -> output
merge fromComparable onlyFirst both onlySecond (Dict d1) (Dict d2) output =
    CoreDict.merge
        (\k v -> onlyFirst (fromComparable k) v)
        (\k v v2 -> both (fromComparable k) v v2)
        (\k v2 -> onlySecond (fromComparable k) v2)
        d1
        d2
        output
