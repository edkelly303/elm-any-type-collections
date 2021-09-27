# Any-type collections

This package allows you to use any custom types, records and other non-`comparable` types as keys for a `Dict` or members for a `Set`. 

## Quick example

```elm
type Id = 
    Id Int

dict = 
    Any.Dict.makeInterface 
        { fromComparable = Id
        , toComparable = \(Id int) -> int
        }

myFirstDict = 
    dict.fromList 
        [ (Id 1, "foo")
        , (Id 2, "bar")
        ]

anotherDict =
    dict.insert (Id 3) "baz" myFirstDict
```

See ["How to use this package"](#how-to-use-this-package) for a more detailed walkthrough.

## Differences from `elm/core`'s `Dict` and `Set`

### 1.  Type signature
The `Dict` and `Set` types in this package each have an additional type parameter, which represents the `comparable` type used to store the key/member under the hood. 
  *  Instead of `Dict comparable value`, we have `Dict key value comparable`
  *  Instead of `Set comparable`, we have `Set member comparable`.

### 2.  Use of `Interface` types
We do not use top-level functions like `Dict.get` or `Set.insert` to interact with the `Dict` and `Set` types from this package. 

Instead, we create `Interfaces` for each type. An `Interface` is simply a record containing functions that mirror the API of `elm/core`'s `Dict` and `Set` implementations.

## Why would you use this package?

*  Its `Dict` and `Set` data structures do not contain any functions, which means you can use them in `Model` and `Msg` types without any caveats. This is a different approach from several other packages, including:
  *  [turboMaCk/any-dict](https://package.elm-lang.org/packages/turboMaCk/any-dict/latest)
  *  [jjant/elm-dict](https://package.elm-lang.org/packages/jjant/elm-dict/latest)
  *  [owanturist/elm-avl-dict](https://package.elm-lang.org/packages/owanturist/elm-avl-dict/latest)
  *  [timo-weike/generic-collections](https://package.elm-lang.org/packages/timo-weike/generic-collections/latest) in its `AutoDict` and `AutoSet` modules

*  It offers similar performance characteristics to the `elm/core` `Dict` and `Set` implementations. Each function has the same Big-O complexity as its `elm-core` equivalent. By contrast:
  *  [pzp1997/assoc-list](https://package.elm-lang.org/packages/pzp1997/assoc-list/latest) has similar performance characteristics to a `List`, which is no problem for small dictionaries but may get slower with larger ones.
  *  [jjant/elm-dict](https://package.elm-lang.org/packages/jjant/elm-dict/latest) takes an interesting approach, which may make it faster in some circumstances and slower in others - check its README for more details.

*  Depending on your preferences, it may feel more ergonomic than packages whose API requires conversion functions to be passed in as an argument each time you call a `Dict`/`Set` function, such as:
  *  [truqu/elm-dictset](https://package.elm-lang.org/packages/truqu/elm-dictset/latest)
  *  [timo-weike/generic-collections](https://package.elm-lang.org/packages/timo-weike/generic-collections/latest) in its `ManualDict` and `ManualSet` modules

## Why _wouldn't_ you use this package?

*  It requires the user to define an `Interface` type for each type of `Dict` or `Set`, as well as functions to convert the key/member type to and from a `comparable` type - so there is a certain amount of boilerplate involved.

*  It may just feel too _weird_ to call `dict.get` instead of `Dict.get`. This type of API, based on a record-of-functions, is not common in Elm packages, and may make the code harder to understand for people who are not familiar with it.

*  It may increase asset size, since the final bundle of compiled code will include all the functions from `elm-core` `Dict` and/or `Set`, even if your code doesn't use them all.

## How to use this package

A common use case is when you have a wrapper type, such as an Id:

```elm
-- module Id exposing (Id, fromInt)

type Id
    = Id Int

toInt : Id -> Int
toInt (Id int) = 
    int

fromInt : Int -> Id
fromInt int = 
    Id int
```

You cannot use an `Id` as a key for an `elm-core` `Dict`, because `Id` is a custom type, and custom types are not `comparable`.

However, with the `Dict` implementation from this package, you can get around the problem. You just have to create an `Interface` by supplying two functions:
*  A function to turn your `Id` type into a `comparable`
*  A function to turn that `comparable` type back into an `Id`

Let's define the `Interface` as a top-level value inside our `Id` module. We'll call it `dict`, and expose it from the module:

```elm
-- module Id exposing (Id, dict, fromInt)

import Any.Dict

dict = 
    Any.Dict.makeInterface 
        { fromComparable = fromInt 
        , toComparable = toInt
        }
```

Now, we can use this `Interface` to create and work with `Id`-keyed `Dict`s anywhere in our code:

```elm
-- module SomeOtherModule exposing (..)

import Any.Dict exposing (Dict)
import Id exposing (Id)

myFirstDict : Dict Id String Int
myFirstDict = 
    Id.dict.fromList 
        [ (Id.fromInt 1, "foo")
        , (Id.fromInt 2, "bar")
        ]

anotherDict : Dict Id String Int
anotherDict =
    Id.dict.insert (Id.fromInt 3) "baz" myFirstDict
```

