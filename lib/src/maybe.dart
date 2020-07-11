import 'exceptions.dart';

/// Represents either an instance of type [T] or an empty value.
///
/// Methods are provided to operate on these values without the need to explicitly check for each case.
/// This is analogous to the Maybe type in Haskell
class Maybe<T> {
  /// The value contained by this [Maybe]. Note that [value] being `null` does not imply that the instance is empty. This library makes a distinction between a 'null' value and an empty instance.
  final T value;

  /// Whether this instance has a value. This returns 'true' if a value is present, 'false' otherwise.
  final bool hasValue;

  /// Constructor to create an empty [Maybe]
  const Maybe.nothing()
      : value = null,
        hasValue = false;

  /// Constructor to create a [Maybe] with a known value.
  const Maybe.just(this.value) : hasValue = true;

  /// Returns the value if one exists. If one doesn't exist, a builder must be provided, which will be called, and the result will be returned.
  ///
  /// For example:
  /// ```dart
  /// Maybe.just(5).getOrDefault(() => 0)  // returns 5
  /// Maybe.nothing().getOrDefault(() => 0)  // returns 5
  /// ```
  T getOrDefault({T Function() orElse}) {
    if (hasValue) return value;

    assert(orElse != null);
    return orElse();
  }

  /// Returns the value if one exists. If one doesn't exist, an error will be thrown.
  ///
  /// Optionally, the [errorBuilder] parameter can be specified to provide more fine-grained control of the error thrown. For example:
  /// ```dart
  /// Maybe.just(5).getOrThrow()  // returns 5
  /// Maybe.nothing.getOrThrow()  // throws MissingValueException
  /// Maybe.nothing.getOrThrow(errorBuilder: () => MyCustomException)  // throws MyCustomException
  /// ```
  T getOrThrow({Function() errorBuilder}) {
    if (hasValue) return value;
    if (errorBuilder != null) throw errorBuilder();
    throw MissingValueException('`getOrThrow` called on an empty `Maybe`');
  }

  /// Maps the value on this [Maybe]. If there is a value, [mapper] is applied and the result is wrapped in a [Maybe]. If there is no value, [Maybe.nothing()] is returned.
  ///
  /// [mapper] must not be null.
  /// For example:
  /// ```dart
  /// Maybe.just(5).map((i) => i * 2)  // returns Maybe.just(10)
  /// Maybe.nothing().map((i) => i * 2)  // returns Maybe.nothing()
  /// ```
  Maybe<R> map<R>(R Function(T) mapper) {
    assert(mapper != null);

    if (!hasValue) return const Maybe.nothing();
    return Maybe.just(mapper(value));
  }

  /// Calls a function on the contained value, if one exists.
  ///
  /// If [hasValue] is [true], [function] must not be 'null'.
  /// Note that [function] must be able to handle 'null' values, since [value] can be 'null'
  /// For example:
  /// ```dart
  /// Maybe.just(5).then(print);  // prints 5
  /// Maybe.nothing().then(print);  // does nothing
  /// ```
  void then(Function(T) function) {
    if (hasValue) {
      assert(function != null);
      function(value);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Maybe) {
      if (!other.hasValue && !hasValue) return true;
      return other.hasValue == hasValue && other.value == value;
    }

    return false;
  }

  @override
  int get hashCode {
    if (!hasValue) return hasValue.hashCode;
    return value.hashCode ^ hasValue.hashCode;
  }

  @override
  String toString() {
    return "Maybe.${hasValue ? 'just' : 'nothing'}.(${hasValue ? value : ''})";
  }
}

/// Takes an [Iterable] of [Maybe]s, and returns all the values for which [hasValue] is 'true'
///
/// Analogous to the 'catMaybes' function from Haskell
/// For example:
/// ```dart
/// final maybes = [ Maybe.just(1), Maybe.nothing(), Maybe.just(3) ];
/// catMaybes(maybes)  // returns [ Maybe.just(1), Maybe.just(3) ]
/// ```
Iterable<T> catMaybes<T>(Iterable<Maybe<T>> maybes) sync* {
  final iterator = maybes.iterator;
  while(iterator.moveNext()) {
    final maybe = iterator.current;
    if (maybe.hasValue) yield maybe.value;
  }
}

