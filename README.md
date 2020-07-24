![Dart CI](https://github.com/cameron1024/haskellite/workflows/Dart%20CI/badge.svg)
![Coverage](https://raw.githubusercontent.com/cameron1024/haskellite/master/coverage_badge.svg)

# haskellite

Haskell-like functionality for Dart

## Features

 - ✅ Open Source
 - ✅ Fully Tested and Documented
 - ✅ Lightweight and Fast
 - ✅ Pure Dart (no Flutter dependencies)
 - ✅ Cross-platform
 
### Types

 - `Maybe<T>` - Represents a value or the absence of a value. 
 - `Either<L, R>` - Represents a value of type `L` or a value of type `R`
 - `Result<T>` - Represents the result of a computation, either succeeding with a value, or failing with an error
 - `RandomVariable<T>` - Describes a variable with a random component, allowing for lazy evaluation and other utilities (convenient reuse/caching/mocking). Inspired by Haskell's strict handling of randomness

### Extensions

 - `Iterable`
    - `head`, `tail`, `init`, `lastMaybe` (to avoid naming conflicts)
    - `fold1` - like `fold` but without an initial value
    - `scan` and `scan1` - like `fold`, but returning an `Iterable` of all intermediate values
    - `intersperse` - inserts elements in between existing elements
 - `int`
    - `1.to(5)` - a replacement for Haskell's `[1..5]`
    - `1.toInfinity()` - a replacement for Haskell's `[1..]`
 
### And More

 - `curry` and `uncurry` - easy partial function application in Dart 
 - `repeat` and `Iterable.cycle` - create a list of repeating values

## Contributing

Suggestions, feedback and pull requests welcome at [Github](https://github.com/cameron1024/haskellite)
