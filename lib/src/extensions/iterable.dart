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
}

/// Creates an iterable that repeats [value] infinitely
Iterable<T> repeat<T>(T value) sync* {
  while (true) {
    yield value;
  }
}
