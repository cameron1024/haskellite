import 'package:haskellite/src/curry.dart';
import 'package:test/test.dart';

void main() {
  test('curry should properly transform a function', () {
    final addUncurried = (int a, int b) => a + b;
    final add = curry(addUncurried);
    expect(add(2)(3), equals(5));
    expect([1, 2, 3].map(add(1)), orderedEquals([2, 3, 4]));
  });

  test('uncurry should properly transform a function', () {
    final addCurried = (int a) => (int b) => a + b;
    final add = uncurry(addCurried);
    expect(add(1, 2), equals(3));
    expect([1, 2, 3].map((e) => add(1, e)), orderedEquals([2, 3, 4]));
  });

  test('default implementations should behave as expected', () {
    expect(add(1)(2), equals(3));
    expect([1, 2, 3].map(add(1)), orderedEquals([2, 3, 4]));

    expect(subtract(1)(2), equals(1));
    expect([1, 2, 3].map(subtract(1)), orderedEquals([0, 1, 2]));

    expect(multiply(2)(3), equals(6));
    expect([1, 2, 3].map(multiply(2)), orderedEquals([2, 4, 6]));

    expect(divide(2)(4), equals(2));
    expect([2, 4, 6].map(divide(2)), orderedEquals([1, 2, 3]));

    expect(mod(2)(4), equals(0));
    expect([3, 4, 5].map(mod(3)), orderedEquals([0, 1, 2]));

    expect(concat(' world')('hello'), equals('hello world'));
  });

  test('swap should behave as expected', () {
    expect(subtract(1)(2), equals(1));
    expect(swap(subtract)(1)(2), equals(-1));
  });

  test('swapU should behave as expected', () {
    expect(uncurry(subtract)(2, 1), equals(-1));
    expect(swapU(uncurry(subtract))(2, 1), equals(1));
  });
}
