module Any.Set exposing
    ( Set
    , Interface
    , makeInterface
    )

{-|


# Data

@docs Set


# Interface

@docs Interface

@docs makeInterface

-}

import Set as CoreSet


{-| A replacement for `elm/core`'s `Set` data structure; the difference is that
members can be of any type, not just `comparable`.

(When I say "any" type, there's one proviso: you must be able to provide a pair
of functions that can convert your member type into a `comparable` and back
again. So this won't work with functions, but it will work with custom types.)

-}
type Set a comparable
    = Set (CoreSet.Set comparable)


{-| An `Interface` is just a record containing functions that mirror the API of
the `elm/core` `Set` module.

The type signature might look daunting, but in practice you can ignore it.

All you need to remember is that if you create an `Interface` called `set`, you
can use it just like the `elm-core` `Set` API:

    -- elm/core
    mySet =
        Set.singleton 1

    -- edkelly303/elm-any-type-collections
    set =
        Any.Set.makeInterface
            { fromComparable = identity
            , toComparable = identity
            }

    mySet =
        set.singleton 1


## The exception: `map`

There is one function in this package's `Set` interface that doesn't quite match
the `elm-core` `Set` API.

The `map` function takes an extra argument:

    -- elm/core
    Set.map :
        (comparable -> comparable2)
        -> Set comparable
        -> Set comparable2

    -- edkelly303/elm-any-type-collections
    set.map :
        (b -> comparable2)
        (a -> b)
        -> Set a comparable
        -> Set b comparable2

This is necessary because `map` is able to change the type of the members of the
`Set` from `a` to `b`. We need to provide a way to turn that `b` into another
`comparable` type so that the resulting `Set` will be able to store it.

-}
type alias Interface a b output comparable comparable2 =
    { empty : Set a comparable
    , singleton : a -> Set a comparable
    , insert : a -> Set a comparable -> Set a comparable
    , remove : a -> Set a comparable -> Set a comparable
    , isEmpty : Set a comparable -> Bool
    , member : a -> Set a comparable -> Bool
    , size : Set a comparable -> Int
    , union : Set a comparable -> Set a comparable -> Set a comparable
    , intersect : Set a comparable -> Set a comparable -> Set a comparable
    , diff : Set a comparable -> Set a comparable -> Set a comparable
    , toList : Set a comparable -> List a
    , fromList : List a -> Set a comparable
    , map : (b -> comparable2) -> (a -> b) -> Set a comparable -> Set b comparable2
    , foldl : (a -> output -> output) -> output -> Set a comparable -> output
    , foldr : (a -> output -> output) -> output -> Set a comparable -> output
    , filter : (a -> Bool) -> Set a comparable -> Set a comparable
    , partition : (a -> Bool) -> Set a comparable -> ( Set a comparable, Set a comparable )
    , toggle : a -> Set a comparable -> Set a comparable
    }


{-| Use `makeInterface` to define an `Interface` for your custom `Set`
type. You need to supply two functions:

1.  `toComparable`, which converts your key type into any `comparable` type (i.e.
    `Int`, `String`, `Float`, or a tuple containing only `comparable` types)
2.  `fromComparable`, which converts that same `comparable` type back into your
    key type.

It's a good idea to define the `Interface` as a top-level value. Once you've
defined the `Interface`, you can use it anywhere in your code without needing to
pass it explicitly to your functions.

For example, here we define the `Interface` as a top-level value called `idSet`:

    type Id
        = Id Int

    idSet =
        makeInterface
            { toComparable = \(Id int) = int
            , fromComparable = Id
            }

    myIdSet =
        idSet.fromList [ Id 1, Id 2, Id 3 ]

    thisIsTrue : Bool
    thisIsTrue =
        idSet.member (Id 2) myIdSet

-}
makeInterface : { toComparable : a -> comparable, fromComparable : comparable -> a } -> Interface a b output comparable comparable2
makeInterface { toComparable, fromComparable } =
    { empty = empty
    , singleton = singleton toComparable
    , insert = insert toComparable
    , remove = remove toComparable
    , isEmpty = isEmpty
    , member = member toComparable
    , size = size
    , union = union
    , intersect = intersect
    , diff = diff
    , toList = toList fromComparable
    , fromList = fromList toComparable
    , map = map fromComparable
    , foldl = foldl fromComparable
    , foldr = foldr fromComparable
    , filter = filter fromComparable
    , partition = partition fromComparable
    , toggle = toggle toComparable
    }


toggle : (a -> comparable) -> a -> Set a comparable -> Set a comparable
toggle toComparable a set =
    if member toComparable a set then
        remove toComparable a set

    else
        insert toComparable a set


partition : (comparable -> a) -> (a -> Bool) -> Set a comparable -> ( Set a comparable, Set a comparable )
partition fromComparable f (Set s) =
    let
        ( s1, s2 ) =
            CoreSet.partition (fromComparable >> f) s
    in
    ( Set s1, Set s2 )


filter : (comparable -> a) -> (a -> Bool) -> Set a comparable -> Set a comparable
filter fromComparable f (Set s) =
    Set (CoreSet.filter (fromComparable >> f) s)


fromList : (a -> comparable) -> (List a -> Set a comparable)
fromList toComparable list =
    Set (CoreSet.fromList (List.map toComparable list))


toList : (comparable -> a) -> (Set a comparable -> List a)
toList fromComparable (Set s) =
    CoreSet.toList s |> List.map fromComparable


diff : Set a comparable -> Set a comparable -> Set a comparable
diff (Set s1) (Set s2) =
    Set (CoreSet.diff s1 s2)


intersect : Set a comparable -> Set a comparable -> Set a comparable
intersect (Set s1) (Set s2) =
    Set (CoreSet.intersect s1 s2)


union : Set a comparable -> Set a comparable -> Set a comparable
union (Set s1) (Set s2) =
    Set (CoreSet.union s1 s2)


size : Set a comparable -> Int
size (Set s) =
    CoreSet.size s


member : (a -> comparable) -> a -> Set a comparable -> Bool
member toComparable a (Set s) =
    CoreSet.member (toComparable a) s


isEmpty : Set a comparable -> Bool
isEmpty (Set s) =
    CoreSet.isEmpty s


remove : (a -> comparable) -> a -> Set a comparable -> Set a comparable
remove toComparable a (Set s) =
    Set (CoreSet.remove (toComparable a) s)


insert : (a -> comparable) -> a -> Set a comparable -> Set a comparable
insert toComparable a (Set s) =
    Set (CoreSet.insert (toComparable a) s)


singleton : (a -> comparable) -> a -> Set a comparable
singleton toComparable a =
    Set (CoreSet.singleton (toComparable a))


empty : Set a comparable
empty =
    Set CoreSet.empty


map : (comparable -> a) -> (b -> comparable2) -> (a -> b) -> Set a comparable -> Set b comparable2
map fromComparable toComparable2 f (Set set) =
    Set (CoreSet.map (fromComparable >> f >> toComparable2) set)


foldl : (comparable -> a) -> (a -> output -> output) -> output -> Set a comparable -> output
foldl fromComparable f acc (Set set) =
    CoreSet.foldl (\a b -> f (fromComparable a) b) acc set


foldr : (comparable -> a) -> (a -> output -> output) -> output -> Set a comparable -> output
foldr fromComparable f acc (Set set) =
    CoreSet.foldr (\a b -> f (fromComparable a) b) acc set
