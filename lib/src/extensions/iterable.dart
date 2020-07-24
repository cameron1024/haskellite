import 'package:haskellite/haskellite.dart';

import '../maybe.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Repeats this [Iterable] infinitely
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].cycle  // 1, 2, 3, 1, 2, 3, 1, 2, 3 ...
  /// ```
  Iterable<T> get cycle sync* {
    while (true) {
      final i = iterator;
      while (i.moveNext()) {
        yield i.current;
      }
    }
  }

  /// Inserts an element between every element of this [Iterable]
  ///
  /// Values are created from [valueBuilder], which is called with the index of the previous element
  /// If [leading] is true, a value will be inserted before any elements of this
  /// If [trailing] is true, a value will be inserted after any elements of this
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].intersperse((_) => -1)  // 1, -1, 2, -1, 3
  /// [1, 2, 3].intersperse((_) => -1, leading: true)  // -1, 1, -1, 2, -1, 3
  /// ```
  Iterable<T> intersperse(T Function(int) valueBuilder, {bool leading = false, bool trailing = false}) sync* {
    assert(valueBuilder != null);
    assert(leading != null);
    assert(trailing != null);

    if (leading) yield valueBuilder(-1);

    final iterator_ = iterator;
    var previousIndex = 0;
    var hasPrevious = false;

    while (iterator_.moveNext()) {
      if (hasPrevious) {
        yield valueBuilder(previousIndex);
        previousIndex++;
      }

      yield iterator_.current;
      hasPrevious = true;
    }

    if (trailing) yield valueBuilder(previousIndex);
  }

  /// The first element, if one exists, [Maybe.nothing] otherwise
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].head  // returns Maybe.just(1)
  /// [].head  // returns Maybe.nothing()
  /// ```
  Maybe<T> get head {
    final _iterator = iterator;
    if (_iterator.moveNext()) return Maybe.just(_iterator.current);
    return Maybe.nothing();
  }

  /// All elements, except the first element.
  ///
  /// If this has no elements, an empty iterable is returned.
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].tail  // returns [2, 3]
  /// ```
  Iterable<T> get tail sync* {
    final _iterator = iterator;
    if (_iterator.moveNext()) {
      while (_iterator.moveNext()) {
        yield _iterator.current;
      }
    }
  }

  /// All elements, except the last element
  ///
  /// If this has no elements, an empty iterable is returned.
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3, 4].init  // returns [1, 2, 3]
  /// ```
  Iterable<T> get init sync* {
    final _iterator = iterator;
    final result = _iterator.moveNext();
    var hasPrevious = false;
    T previousValue;
    if (result) {
      do {
        if (hasPrevious) yield previousValue;
        previousValue = _iterator.current;
        hasPrevious = true;
      } while (_iterator.moveNext());
    }
  }

  /// Returns the last element, or [Maybe.nothing] if this is empty.
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].lastMaybe  // returns Maybe.just(3)
  /// [].lastMaybe  // returns Maybe.nothing();
  /// ```
  Maybe<T> get lastMaybe {
    final _iterator = iterator;
    T lastValue;
    if (!_iterator.moveNext()) return const Maybe.nothing();
    do {
      lastValue = _iterator.current;
    } while (_iterator.moveNext());
    return Maybe.just(lastValue);
  }

  /// A variant of [Iterable.fold] with no base case, requiring at least 1 element.
  ///
  /// If this has no elements, [Maybe.nothing] is returned.
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].fold1((a, b) => a + b)  // returns 6
  /// ```
  Maybe<T> fold1(T Function(T, T) combine) {
    final _iterator = iterator;
    if (!_iterator.moveNext()) return const Maybe.nothing();
    return Maybe.just(tail.fold(_iterator.current, combine));
  }

  /// Similar to [fold], except it returns an `Iterable` of all successive reduced values
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].scan(0, (a, b) => a + b)  // returns [0, 1, 3, 6]
  /// [].scan(0, (a, b) => a + b)  // returns [0]
  /// ```
  Iterable<T> scan(T initialValue, T Function(T, T) combine) sync* {
    var previous = initialValue;
    yield previous;
    final _iterator = iterator;
    while (_iterator.moveNext()) {
      previous = combine(previous, _iterator.current);
      yield previous;
    }
  }

  /// Similar to [Iterable.fold1], except it returns an `Iterable` of all successive reduced values
  ///
  /// For example:
  /// ```dart
  /// [1, 2, 3].scan1((a, b) => a + b)  // returns [1, 3, 6]
  /// [0].scan1((a, b) => a + b)  // returns []
  /// ```
  Iterable<T> scan1(T Function(T, T) combine) sync* {
    final _iterator = iterator;
    if (_iterator.moveNext()) {
      var value = _iterator.current;
      yield value;
      while (_iterator.moveNext()) {
        value = combine(value, _iterator.current);
        yield value;
      }
    }
  }
}

/// Creates an iterable that repeats [value] [count] times, or indefinitely if [count] is not provided.
///
/// For example:
/// ```dart
/// repeat(4)  // returns [4, 4, 4, 4, ...]
/// repeat(4, count: 2)  // returns [4, 4]
/// ```
Iterable<T> repeat<T>(T value, {int count}) sync* {
  if (count == null) {
    while (true) {
      yield value;
    }
  } else {
    for (var i = 0; i < count; i++) {
      yield value;
    }
  }
}
