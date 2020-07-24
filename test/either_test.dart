import 'package:haskellite/haskellite.dart';
import 'package:test/test.dart';

final _failsAssert = throwsA(isA<AssertionError>());

const _string = 'Hello';
const _int = 10;

const _left = Either<String, int>.left(_string);
const _right = Either<String, int>.right(_int);

final _stringMapper = (String s) => s + ' world';
final _mappedString = _stringMapper(_string);
final _intMapper = (int i) => i * 2;
final _mappedInt = _intMapper(_int);

final _eitherMapper = (Either<String, int> either) => either.map(
      leftMapper: _stringMapper,
      rightMapper: _intMapper,
    );

void main() {
  test('either constructors should behave as expected', () {
    expect(_left.isLeft, isTrue);
    expect(_left.isRight, isFalse);
    expect(_right.isLeft, isFalse);
    expect(_right.isRight, isTrue);

    expect(_left.left, equals(_string));
    expect(_left.right, isNull);
    expect(_right.right, equals(_int));
    expect(_right.left, isNull);
  });

  test('map should preserve left/right state', () {
    expect(_eitherMapper(_left).isLeft, isTrue);
    expect(_eitherMapper(_right).isRight, isTrue);
  });

  test('map should map values correctly', () {
    expect(_eitherMapper(_left).left, equals(_mappedString));
    expect(_eitherMapper(_left).right, isNull);
    expect(_eitherMapper(_right).right, equals(_mappedInt));
    expect(_eitherMapper(_right).left, isNull);
  });

  test('map should throw an error if corresponding mapper is null', () {
    final mapLeft = (Either<String, int> either) => either.map(leftMapper: _stringMapper);
    final mapRight = (Either<String, int> either) => either.map(rightMapper: _intMapper);

    expect(() => mapLeft(_left), anything);
    expect(() => mapLeft(_right), _failsAssert);

    expect(() => mapRight(_left), _failsAssert);
    expect(() => mapRight(_right), anything);
  });

  test('reversed should properly reverse values', () {
    expect(_left.reversed, equals(Either<int, String>.right(_string)));
    expect(_right.reversed, equals(Either<int, String>.left(_int)));
  });

  test('leftAsMaybe and rightAsMaybe should return expected values', () {
    expect(_left.leftAsMaybe, equals(Maybe.just(_string)));
    expect(_left.rightAsMaybe, equals(Maybe.nothing()));
    expect(_right.rightAsMaybe, equals(Maybe.just(_int)));
    expect(_right.leftAsMaybe, equals(Maybe.nothing()));
  });

  test('leftOrDefault and rightOrDefault should return expected values', () {
    expect(_left.leftOrDefault(() => 'default'), equals(_string));
    expect(_right.leftOrDefault(() => 'default'), equals('default'));
    expect(_right.rightOrDefault(() => 0), equals(_int));
    expect(_left.rightOrDefault(() => 0), equals(0));
  });

  test('leftOrDefault and rightOrDefault should throw errors if defaultBuilder not provided when needed', () {
    expect(() => _right.leftOrDefault(null), _failsAssert);
    expect(() => _left.rightOrDefault(null), _failsAssert);
  });

  test('lefts and rights should properly separate lists', () {
    Iterable<Either<String, int>> iterable = [
      Either.left('1'),
      Either.right(2),
      Either.left('3'),
      Either.right(4),
    ];

    Iterable<String> expectedLefts = ['1', '3'];
    Iterable<int> expectedRights = [2, 4];

    expect(lefts(iterable), orderedEquals(expectedLefts));
    expect(rights(iterable), orderedEquals(expectedRights));
    expect(lefts(iterable), isNot(orderedEquals(expectedRights)));
    expect(rights(iterable), isNot(orderedEquals(expectedLefts)));
  });
}
