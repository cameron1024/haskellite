
import 'package:haskellite/haskellite.dart';
import 'package:test/test.dart';

void main() {
  test('head should return the first element if one exists, or nothing otherwise', () {
    expect([1, 2, 3].head, equals(Maybe.just(1)));
    expect([].head, equals(Maybe.nothing()));
  });

  test('tail should return the correct values', () {
    expect([1, 2, 3].tail, orderedEquals([2, 3]));
    expect([1].tail, orderedEquals([]));
    expect([].tail, orderedEquals([]));
  });

  test('init should return the correct values', () {
    expect([1, 2, 3].init, orderedEquals([1, 2]));
    expect([1, 2, 3, 4].init, orderedEquals([1, 2, 3]));
    expect([1].init, orderedEquals([]));
    expect([].init, orderedEquals([]));
  });

  test('lastMaybe should return the last element if one exists, or nothing otherwise', () {
    expect([1, 2, 3].lastMaybe, equals(Maybe.just(3)));
    expect([].lastMaybe, equals(Maybe.nothing()));
  });

  test('fold1 should give expected values', () {
    final add = (int a, int b) => a + b;
    expect([1, 2, 3].fold1(add), equals(Maybe.just(6)));
    expect([1, 2].fold1(add), equals(Maybe.just(3)));
    expect([1].fold1(add), equals(Maybe.just(1)));
    expect(<int>[].fold1(add), equals(Maybe.nothing()));
  });

  test('intersperse should behave as expected', () {
    expect([1, 2, 3].intersperse((_) => 0), orderedEquals(<int>[1, 0, 2, 0, 3]));
    expect([1, 2, 3].intersperse((i) => i), orderedEquals(<int>[1, 0, 2, 1, 3]));
    expect([1, 2, 3].intersperse((i) => i, leading: true, trailing: true), orderedEquals(<int>[-1, 1, 0, 2, 1, 3, 2]));
    expect(<int>[].intersperse((i) => i), orderedEquals(<int>[]));
    expect(<int>[].intersperse((i) => i, leading: true, trailing: true), orderedEquals(<int>[-1, 0]));
  });

  test('repeat should behave as expected', () {
    expect(repeat(1).take(5), orderedEquals([1, 1, 1, 1, 1]));
    expect(repeat(1, count: 3), orderedEquals([1, 1, 1]));
  });

  test('scan should behave as expected', () {
    expect(<num>[1, 2, 3].scan(0, uncurry(add)), orderedEquals([0, 1, 3, 6]));
    expect(<num>[].scan(0, uncurry(add)), orderedEquals([0]));
  });

  test('scan1 should behave as expected', () {
    expect(<num>[1, 2, 3].scan1(uncurry(add)), orderedEquals([1, 3, 6]));
    expect(<num>[].scan1(uncurry(add)), orderedEquals([]));
  });

  test('cycle should behave as expected', () {
    expect([1].cycle.take(4), orderedEquals([1, 1, 1, 1]));
    expect([1, 2].cycle.take(4), orderedEquals([1, 2, 1, 2]));
  });
}