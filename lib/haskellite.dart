/// Haskell-like functionality in Dart
///
/// Haskell uses certain design patterns that make reading and reasoning about programs easier. The goal of this library is to try to bring some of that to Dart. The APIs in this library are either close matches to, or inspired by APIs that exist in Haskell. However, there will be notable differences given some of Dart's inherent limitations.

library haskellite;

export 'src/either.dart';
export 'src/maybe.dart';
export 'src/result.dart';
export 'src/exceptions.dart';
export 'src/random_variable.dart';
export 'src/extensions/int.dart';
export 'src/extensions/iterable.dart';
