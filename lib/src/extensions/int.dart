extension IntExtension on int {

  /// Creates a list containing all from [this] to [end], in intervals of [step].
  ///
  /// Inspired by Haskell's `[1..n]` syntax. Providing a negative [step] is allowed, and behaves as if the same positive [step] was provided. [step] must be non null and must not be 0.
  /// [this] is always included in the list. It is possible for a value greater than [end] to be included in the list. For example, [1.to(2, step: 3)] returns [[1, 4]]
  ///
  /// For example:
  /// ```dart
  /// 1.to(5)  // [1, 2, 3, 4, 5]
  /// 1.to(5, step: 2)  // [1, 3, 5]
  /// ```
  List<int> to(int end, {int step = 1}) {
    assert(end != null);
    assert(step != null);
    assert(step != 0);

    if (this == end) return [this];

    step = step.abs();
    var ascending = end > this;
    if (!ascending) step *= -1;

    final list = <int>[];
    var continue_ = true;
    var i = this;
    while (continue_) {
      if (ascending ? i >= end : i <= end) continue_ = false;
      list.add(i);
      i += step;
    }
    return list;
  }

  /// Creates an infinite list starting from [this], in intervals of [step].
  ///
  /// Inspired by Haskell's `[1..]` syntax.
  /// If [step] is negative, the
  /// [step] must be non-null.
  ///
  /// For example:
  /// ```dart
  /// 1.toInfinity()  // 1, 2, 3, 4, 5...
  /// 1.toInfinity(step: 2)  // 1, 3, 5, 7, 9...
  /// 1.toInfinity(step: -1)  // 1, 0, -1, -2, -3...
  /// ```
  Iterable<int> toInfinity({int step = 1}) sync* {
    assert(step != null);
    var i = this;
    while (true) {
      yield i;
      i += step;
    }
  }


}