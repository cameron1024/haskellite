import 'package:haskellite/src/exceptions.dart';
import 'package:haskellite/src/maybe.dart';
import 'package:test/test.dart';

Matcher get _failsAssert => throwsA(isA<AssertionError>());

const _value = "Hello";
final _stringMapper = (String s) => s + " world";
final _mappedValue = _stringMapper(_value);
Maybe<String> get _maybeWithValue => Maybe.just(_value);
Maybe<String> get _emptyMaybe => const Maybe.nothing();


void main() {
  test("maybe constructors should return expected values", () {
    expect(_maybeWithValue.hasValue, isTrue);
    expect(_emptyMaybe.hasValue, isFalse);

    expect(_maybeWithValue.value, equals(_value));
    expect(_emptyMaybe.value, isNull);
  });

  test("getOrDefault should return the value if one is preset", () {
    expect(_maybeWithValue.value, equals(_value));
  });

  test("getOrDefault should return its builder if no value is present", () {
    expect(_emptyMaybe.getOrDefault(orElse: () => "default"), equals("default"));
  });

  test("getOrDefault should throw an assertion error if no value is present and no builder specified", () {
    expect(() => _emptyMaybe.getOrDefault(), throws);
  });

  test("getOrThrow should return the value if one is present", () {
    expect(_maybeWithValue.getOrThrow(), equals(_value));
  });

  test("getOrThrow should throw the specified exception if no value present", () {
    final error = Error();
    final errorBuilder = () => error;
    expect(() => _emptyMaybe.getOrThrow(errorBuilder: errorBuilder), throwsA(error));
  });

  test("getOrThrow should throw a default exception if none provided", () {
    expect(() => _emptyMaybe.getOrThrow(), throwsA(isA<MissingValueException>()));
  });

  test("map should map a value correctly", () {
    expect(_maybeWithValue.map(_stringMapper), equals(Maybe.just(_mappedValue)));
    expect(_emptyMaybe.map(_stringMapper), equals(_emptyMaybe));
  });

  test("map should throw an error if no function provided", () {
    expect(() => _maybeWithValue.map(null), _failsAssert);
  });

  test("then should call the given function if a value is present", () {
    int timesCalled = 0;
    final function = (_) => timesCalled++;
    _maybeWithValue.then(function);
    expect(timesCalled, equals(1));
  });

  test("then should not call the given function if no value is present", () {
    int timesCalled = 0;
    final function = (_) => timesCalled++;
    _emptyMaybe.then(function);
    expect(timesCalled, equals(0));
  });

  test("then should throw an error if no function is provided and a value is present", () {
    expect(() => _maybeWithValue.then(null), _failsAssert);
  });

  test("maybe equality should behave as expected", () {
    expect(_emptyMaybe, equals(_emptyMaybe));
    expect(_maybeWithValue, equals(_maybeWithValue));
    expect(_emptyMaybe, equals(_emptyMaybe.map((s) => s)));
    expect(_maybeWithValue, equals(_maybeWithValue.map((s) => s)));
    expect(_emptyMaybe, isNot(equals(_maybeWithValue)));
    expect(_maybeWithValue, isNot(equals(_emptyMaybe)));
    expect(_maybeWithValue, isNot(equals(Maybe.just("world"))));
  });

  test("catMaybes should behave as expected", () {
    expect(catMaybes([]), equals(Iterable.empty()));

    final maybeList = [
      Maybe.just(1),
      Maybe.just(2),
      Maybe.nothing(),
      Maybe.just(3),
    ];

    expect(catMaybes(maybeList), orderedEquals([1, 2, 3]));
    expect(catMaybes(maybeList), isNot(orderedEquals([1, 2, 3, 4])));
  });

}