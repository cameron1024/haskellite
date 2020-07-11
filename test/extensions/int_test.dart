import 'package:haskellite/src/extensions/int.dart';
import 'package:test/test.dart';

Matcher get _failsAssert => throwsA(isA<AssertionError>());

void main () {
  test('int.to should create lists with expected values', () {
    expect(1.to(5), orderedEquals([1, 2, 3, 4, 5]));
    expect(5.to(1), orderedEquals([5, 4, 3, 2, 1]));
    expect(3.to(-3), orderedEquals([3, 2, 1, 0, -1, -2, -3]));

    expect(1.to(5, step: 3), orderedEquals([1, 4, 7]));
    expect(1.to(5, step: -3), orderedEquals([1, 4, 7]));

  });

  test('int.to should throw exception when called with invalid arguments', () {
    expect(() => 1.to(null), _failsAssert);
    expect(() => 1.to(5, step: null), _failsAssert);
    expect(() => 1.to(5, step: 0), _failsAssert);
  });

  test('int.toInfinity should produce expected values', () {
    expect(0.toInfinity().take(10), orderedEquals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
  });

  test('int.toInfinity should throw an exception when called with invalid arguments', () {
    expect(() => 1.toInfinity(step: null), _failsAssert);
  });

}