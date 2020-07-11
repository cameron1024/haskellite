
import 'maybe.dart';

/// An [Either<L, R>] represents a value whose type is either [L] or [R].
///
/// This is analogous to the Either type in Haskell, or [union types](https://en.wikipedia.org/wiki/Union_type) more generally
class Either<L, R> {

  /// The left value of this instance
  ///
  /// For example:
  /// ```dart
  /// Either<String, int>.left("hello").left  // returns "hello"
  /// Either<String, int>.right(5).left  // returns null
  /// ```
  final L left;

  /// The right value of this instance
  ///
  /// For example:
  /// ```dart
  /// Either<String, int>.left("hello").right  // returns null
  /// Either<String, int>.right(5).right  // returns 5
  /// ```
  final R right;

  /// Returns `true` if this instance was created with [Either.left], `false` otherwise
  ///
  /// For example:
  /// ```dart
  /// Either<String, int>.left("hello").isLeft  // returns true
  /// Either<String, int>.right(5).isLeft  // returns false
  /// ```
  final bool isLeft;

  /// Returns `true` if this instance was created with [Either.right], `false` otherwise
  ///
  /// For example:
  /// ```dart
  /// Either<String, int>.left("hello").isRight  // returns false
  /// Either<String, int>.right(5).isRight  // returns true
  /// ```
  bool get isRight => !isLeft;

  /// Constructor for creating an instance with a value of type [L]
  const Either.left(this.left)
      : right = null,
        isLeft = true;

  /// Constructor for creating an instance with a value of type [R]
  const Either.right(this.right)
      : left = null,
        isLeft = false;

  /// Map an [Either<L, R>] to an [Either<A, B>]. This function takes a [leftMapper] and a [rightMapper], to handle the left/right cases respectively.
  ///
  /// If [map] is called on a left either, [leftMapper] but be non-null, and vice versa
  /// For example:
  /// ```dart
  /// final leftMapper = (String left) => '$left world';
  /// final rightMapper = (int i) => i * 2;
  /// final eitherMapper = (Either<String, int> either) => either.map(leftMapper: leftMapper, rightMapper: rightMapper);
  ///
  /// eitherMapper(Either.left("hello")  // returns Either.left("hello world")
  /// eitherMapper(Either.right(5)  )// returns Either.right(10)
  /// ```
  Either<A, B> map<A, B>({A Function(L) leftMapper, B Function(R) rightMapper}) {
    if (isLeft) {
      assert(leftMapper != null);
      return Either.left(leftMapper(left));
    } else {
      assert(rightMapper != null);
      return Either.right(rightMapper(right));
    }
  }

  /// Returns the left side as a [Maybe]
  ///
  /// For example:
  /// ```dart
  /// Either<int, String>.left(5).leftAsMaybe  // returns Maybe.just(5)
  /// Either<int, String>.right("hello").leftAsMaybe  // returns Maybe.nothing()
  /// ```
  Maybe<L> get leftAsMaybe => isLeft ? Maybe.just(left) : const Maybe.nothing();

  /// Returns the right side as a [Maybe]
  ///
  /// For example:
  /// ```dart
  /// Either<int, String>.right("hello").rightAsMaybe  // returns Maybe.just("hello")
  /// Either<int, String>.left(5).rightAsMaybe  // returns Maybe.nothing()
  /// ```
  Maybe<R> get rightAsMaybe => isRight ? Maybe.just(right) : const Maybe.nothing();


  /// Returns the [left] value if one exists, or calls [defaultBuilder] otherwise.
  ///
  /// If [isLeft] is `false`, [defaultBuilder] must be non-null
  /// For example:
  /// ```dart
  /// Either<int, String>.left(5).leftOrDefault(() => 0)  // returns 5
  /// Either<int, String>.right("hello").leftOrDefault(() => 0)  // returns 0
  /// ```
  L leftOrDefault(L Function() defaultBuilder) {
    if (isLeft) return left;
    assert(defaultBuilder != null);
    return defaultBuilder();
  }

  /// Returns the [right] value if one exists, or calls [defaultBuilder] otherwise.
  ///
  /// If [isRight] is `false`, [defaultBuilder] must be non-null
  /// For example:
  /// ```dart
  /// Either<int, String>.right("hello").rightOrDefault(() => "default")  // returns "hello"
  /// Either<int, String>.left(5).rightOrDefault(() => "default")  // returns "default"
  /// ```
  R rightOrDefault(R Function() defaultBuilder) {
    if (isRight) return right;
    assert(defaultBuilder != null);
    return defaultBuilder();
  }

  /// Returns an [Either] with the types reversed
  ///
  /// For example:
  /// ```dart
  ///
  /// final reversed = Either<String, int>.left("hello").reversed;
  /// reversed.isRight  // returns true
  /// reversed.right  // returns "hello"
  ///
  /// ```
  Either<R, L> get reversed => isLeft ? Either<R, L>.right(left) : Either<R, L>.left(right);

  @override
  String toString() {
    return "Either.${isLeft ? 'left' : 'right'}.(value: ${isLeft ? left : right})";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Either &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          right == other.right &&
          isLeft == other.isLeft;

  @override
  int get hashCode => left.hashCode ^ right.hashCode ^ isLeft.hashCode;
}
/// Takes an [Iterable] of [Either]s, and returns an [Iterable] containing only the elements created with [Either.left]
///
/// For example:
/// ```dart
/// final eithers = <Either<String, int>>[ Either.left('1'), Either.right(2), Either.left('3'), Either.right(4) ];
/// lefts(eithers)  // returns [ Either.left('1'), Either.left('3') ],
/// ```
Iterable<A> lefts<A, B>(Iterable<Either<A, B>> eithers) sync* {
  final iterator = eithers.iterator;
  while (iterator.moveNext()) {
    final either = iterator.current;
    if (either.isLeft) yield either.left;
  }


}

/// Takes an [Iterable] of [Either]s, and returns an [Iterable] containing only the elements created with [Either.right]
///
/// For example:
/// ```dart
/// final eithers = <Either<String, int>>[ Either.left('1'), Either.right(2), Either.left('3'), Either.right(4) ];
/// rights(eithers)  // returns [ Either.right(2), Either.right(4) ],
/// ```
Iterable<B> rights<A, B>(Iterable<Either<A, B>> eithers) sync* {
  final iterator = eithers.iterator;
  while(iterator.moveNext()) {
    final either = iterator.current;
    if (either.isRight) yield either.right;
  }
}

