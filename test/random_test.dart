
import 'package:haskellite/src/random_variable.dart';
import 'package:test/test.dart';

Matcher get _failsAssert => throwsA(isA<AssertionError>());
const _seed = 12345;
const _iterationCount = 10;

void main() {
  test('random builders should fail on invalid parameters', () {
    expect(() => randomInt(secure: true, seed: _seed), _failsAssert);
    expect(() => randomInt(offset: null), _failsAssert);
    expect(() => randomDouble(secure: true, seed: _seed), _failsAssert);
    expect(() => randomBool(secure: true, seed: _seed), _failsAssert);
    expect(() => randomizedList([1], secure: true, seed: _seed), _failsAssert);
    expect(() => randomListItem([1], secure: true, seed: _seed), _failsAssert);
  });
  
  test('random values with a given seed should provide the same values', () {
    final random1 = randomInt(seed: _seed);
    final random2 = randomInt(seed: _seed);

    final values1 = Iterable.generate(_iterationCount, (_) => random1.next);
    final values2 = Iterable.generate(_iterationCount, (_) => random2.next);

    expect(values1, orderedEquals(values2));
  });

  test('random ints with an offset should produce expected values', () {
    for (var i = 0; i < _iterationCount; i++) {
      expect(randomInt(max: 1, offset: i).next, equals(i));
    }
  });

  test('custom variables should return values provided', () {
    var called = false;
    final function = () {
      called = true;
      return 0;
    };

    final variable = randomWrappedFactory(function);
    expect(called, isFalse);

    final value = variable.next;
    expect(value, equals(0));

    expect(called, isTrue);
  });

  test('precached variables should cache values properly', () {
    final depth = 10;
    var callCount = 0;

    final base = randomWrappedFactory(() => callCount++);
    final variable = PrecachedRandomVariable(base, depth: depth);

    expect(callCount, equals(depth));
    variable.next;
    expect(callCount, equals(depth + 1));
  });

  test('changing the precache depth should load new values if needed', () {
    final depth = 10;
    var callCount = 0;

    final base = randomWrappedFactory(() => callCount++);
    final variable = PrecachedRandomVariable(base, depth: depth);

    expect(callCount, equals(depth));

    variable.depth = 20;
    expect(callCount, equals(20));

    variable.depth = 5;
    expect(callCount, equals(20));

    variable.depth = 20;
    expect(callCount, equals(20));

    variable.depth = 25;
    expect(callCount, equals(25));
  });

  test('creating a precached variable should fail if invalid arguments given', () {
    expect(() => PrecachedRandomVariable(null), throwsA(isA<AssertionError>()));
    expect(() => PrecachedRandomVariable(randomInt(), depth: null), throwsA(isA<AssertionError>()));
    expect(() => PrecachedRandomVariable(randomInt(), depth: -5), throwsA(isA<AssertionError>()));
  });

  test('shuffled list should return new lists', () {
    final list = [1, 2, 3, 4, 5];
    final variable = randomizedList(list);

    final shuffled = variable.next;
    expect(list, unorderedEquals(shuffled));
    expect(list, isNot(same(shuffled)));

    shuffled.add(6);
    expect(list, isNot(unorderedEquals(shuffled)));
    expect(list, isNot(same(shuffled)));

  });

  test('weighted variable should produce expected values', () {
    expect(WeightedVariable({'hello': 1}).next, equals('hello'));
    expect(WeightedVariable({'hello': 9999}).next, equals('hello'));
  });

  test('weighted variable should throw error if invalid weights provided', () {
    expect(() => WeightedVariable({}), _failsAssert);
    expect(() => WeightedVariable({'hello': -1}), _failsAssert);
    expect(() => WeightedVariable({'hello': 0}), _failsAssert);

    final almostValidWeights = {
      'hello': 1,
      'world': 2.2,
      '!': 3,
      'never exists': 0,
      'fail': -4
    };
    expect(() => WeightedVariable(almostValidWeights), _failsAssert);
  });


}