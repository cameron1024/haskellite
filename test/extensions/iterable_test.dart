import 'package:haskellite/src/extensions/iterable.dart';
import 'package:test/test.dart';

void main() {
  test('intersperse', () {
    expect([1, 2, 3].intersperse((_) => 0), orderedEquals(<int>[1, 0, 2, 0, 3]));
    expect([1, 2, 3].intersperse((i) => i), orderedEquals(<int>[1, 0, 2, 1, 3]));
    expect([1, 2, 3].intersperse((i) => i, leading: true, trailing: true), orderedEquals(<int>[-1, 1, 0, 2, 1, 3, 2]));
    expect(<int>[].intersperse((i) => i), orderedEquals(<int>[]));
    expect(<int>[].intersperse((i) => i, leading: true, trailing: true), orderedEquals(<int>[-1, 0]));

  });
}