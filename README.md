# Any-type collections

## Why use this package?

This package can be used as a replacement for the `Dict` and `Set` modules in `elm/core`.

Its main benefit is that it allows you to use any type (except functions) as a key in `Dict`s or a member in `Set`s. 

By contrast, the `elm-core` implementations of `Dict` and `Set` restrict you to using `comparable` types as keys/members. In Elm, the `comparable` types are `Int`, `Float`, `String`, and tuples that contain only `comparable` types. Custom types and records are not `comparable`.

There are several other packages in the Elm package registry that already allow you to use non-comparable types in `Dict`- and `Set`-like data structures. However, this package takes a different approach, and has different trade-offs, from any other package I have seen.

### Advantages
*  It uses a data structure that does not contain any functions, making it safe to use in `Model` and `Msg` types.
*  It provides a relatively type-safe interface that makes it difficult (though not impossible) to misuse.
*  It offers similar performance characteristics to the `elm/core` implementations (i.e. each function has the same Big-O complexity as its `elm-core` equivalent).

### Disadvantages
*  It requires the user to define an `Interface` type for each type of `Dict` or `Set`.
*  It may have a small impact on asset size, since the final bundle will include all the functions from `elm-core` `Dict` and/or `Set`, even if your code doesn't use them all.

## Differences from `elm/core`'s `Dict` and `Set`

### 1.  Type signature
The `Dict` and `Set` types in this package each have an additional type parameter, which represents the `comparable` type used to store the key/member under the hood. 
  *  Instead of `Dict comparable value`, we have `Dict key value comparable`
  *  Instead of `Set comparable`, we have `Set member comparable`.

### 2.  Use of `Interface` types
We do not use top-level functions like `Dict.get` or `Set.insert` to interact with the `Dict` and `Set` types from this package. 

Instead, we create `Interfaces` for each type. An `Interface` is simply a record containing functions that mirror the API of `elm/core`'s `Dict` and `Set` implementations.

## How to use this package

A common use case is when you have a wrapper type, such as an Id:

```elm
module Id exposing (Id)

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
module Id exposing (Id, dict)

import Any.Dict

...

dict = 
    Any.Dict.makeInterface 
        { fromComparable = fromInt 
        , toComparable = toInt
        }
```

Now, we can use this `Interface` to create and work with `Id`-keyed `Dict`s anywhere in our code:

```elm
module SomeOtherModule exposing (..)

import Any.Dict exposing (Dict)
import Id exposing (Id)

myCoolDict : Dict Id String Int
myCoolDict = 
    Id.dict.fromList 
        [ (Id 1, "foo")
        , (Id 2, "bar")
        ]

evenCoolerDict : Dict Id String Int
evenCoolerDict =
    Id.dict.insert (Id 3) "baz" myCoolDict
```

