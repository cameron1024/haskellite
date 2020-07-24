import 'dart:collection';
import 'dart:math';

/// Represents a random, lazily-evaluated variable of type <T>
abstract class RandomVariable<T> {
  /// Yields the next random value
  ///
  /// For example:
  /// ```dart
  /// final variable = getSomeRandomVariable();
  /// variable.next  // returns a random value as determined by the implementation of variable
  /// ```
  T get next;
}

/// Produces a [RandomVariable] that produces ints from [Random.nextInt].
///
/// A [max] can be provided to limit the size of the produced ints.
/// A [seed] can be provided to seed the underlying [Random].
/// Setting [secure] to true uses [Random.secure] as the underlying [Random] instance, and disallows the use of [seed].
/// Optionally, an [offset] can be specified, which will be added to the final result
///
/// For example:
/// ```dart
/// final variable = randomInt(max: 1000);
/// variable.next  // returns a random int between 0 and 999 inclusive
///
/// final dice = randomInt(max: 6, offset: 1);
/// dice.next  // returns a random int between 1 and 6 inclusive
/// ```
RandomVariable<int> randomInt({int seed, bool secure = false, int max = 256, int offset = 0}) => _BaseRandomInt(secure: secure, seed: seed, max: max, offset: offset);

/// Produces a [RandomVariable] that produces doubles from [Random.nextDouble].
///
/// A [seed] can be provided to seed the underlying [Random].
/// Setting [secure] to true uses [Random.secure] as the underlying [Random] instance, and disallows the use of [seed].
///
/// For example:
/// ```dart
/// final variable = randomDouble();
/// variable.next  // returns a random double
/// ```
RandomVariable<double> randomDouble({int seed, bool secure = false}) => _BaseRandomDouble(seed: seed, secure: secure);

/// Produces a [RandomVariable] that produces bools from [Random.nextBool].
///
/// A [seed] can be provided to seed the underlying [Random].
/// Setting [secure] to true uses [Random.secure] as the underlying [Random] instance, and disallows the use of [seed].
///
/// For example:
/// ```dart
/// final variable = randomBool();
/// variable.next  // returns a random bool
/// ```
RandomVariable<bool> randomBool({int seed, bool secure = false}) => _BaseRandomBool(seed: seed, secure: secure);

/// Produces a [RandomVariable] that maps values from another [RandomVariable]
///
/// When [RandomVariable.next] is called, [base.next] is called, and [mapper] is applied to it and the value is returned.
/// [base] and [mapper] must be non-null.
///
/// For example:
/// ```dart
/// final variable = randomMapped(randomBool, (b) => b ? "hello" : "goodbye");
/// variable.next  // returns a random string that is either "hello" or "goodbye"
/// ```
RandomVariable<R> randomMapped<T, R>(RandomVariable<T> base, R Function(T) mapper) => _MappedRandomVariable(mapper, base);

/// Produces a [RandomVariable] that takes a list and returns a shallow copie with the elements in a randomized order.
///
/// A [seed] can be provided to seed the underlying [Random]. Setting [secure] to true uses [Random.secure] as the underlying [Random] instance, and disallows the use of [seed].
///
/// For example:
/// ```dart
/// final list = [1, 2, 3, 4]
/// final variable = randomizedList(list);
/// variable.next  // returns a new list, containing [1, 2, 3, 4] in a random order
/// ```
RandomVariable<List<T>> randomizedList<T>(List<T> list, {int seed, bool secure = false}) {
  assert(list != null);
  assert(list.isNotEmpty);
  assert(secure == false || seed == null);
  return _RandomizedList(list, seed: seed, secure: secure);
}

/// Produces a [RandomVariable] that takes a list and returns random element from the list
///
/// A [seed] can be provided to seed the underlying [Random]. Setting [secure] to true uses [Random.secure] as the underlying [Random] instance, and disallows the use of [seed].
/// [list] must be non-null and must contain at least 1 element
///
/// For example:
/// ```dart
/// final list = [1, 2, 3];
/// final variable = randomListItem(list);
/// variable.next  // returns 1, 2 or 3 at random
/// ```
RandomVariable<T> randomListItem<T>(List<T> list, {int seed, bool secure = false}) {
  assert(list != null);
  assert(list.isNotEmpty);
  assert(secure == false || seed == null);
  return _RandomListItem(list, seed: seed, secure: secure);
}

/// Produces a [RandomVariable] that calls a user-provided [factory] to produce values.
///
/// [factory] must not be null.
/// Note that, given [factory] is user-provided, the randomness/distribution/entropy of the values produced depend entirely on the implementation of [factory].
///
/// For example:
/// ```dart
/// final variable = randomWrappedFactory(() => 1);
/// variable.next  // returns 1
///
/// final timeIsEven = () => DateTime.now().millisecondsSinceEpoch % 2 == 0;
/// final clockVariable = randomWrappedFactory(() => timeIsEven);
/// clockVariable.next  // returns a "random" bool
/// ```
RandomVariable<T> randomWrappedFactory<T>(T Function() factory) => _CustomRandom(factory);

/// Produces a [RandomVariable] representing a [Markov Chain](https://en.wikipedia.org/wiki/Markov_chain)
///
/// [function] takes the previous value as an input, and returns the next value.
/// [function] must be non-null.
/// If an [initialValue] is provided, it will be used as the input to [function] the first time [RandomVariable.next] is called
///
/// For example:
/// ```dart
/// final throwsErrorOnNull = (int i) {
///   assert(i != null);
///   return i + 1;
/// }
///
/// randomMarkov(throwsErrorOnNull).next  // throws an 'AssertionError'
/// randomMarkov(throwsErrorOnNull, initialValue: 0).next  // returns 1
/// ```
RandomVariable<T> randomMarkov<T>(T Function(T) function, {T initialValue}) {
  assert(function != null);
  return _MarkovVariable(function, previous: initialValue);
}


/// Wraps a [RandomVariable] with one that will not emit the same value within a given interval.
///
/// Any repeated values returned by [baseVariable] will be discarded, and as such you will not necessarily receive values in the same order.
/// Note that it is possible to get into a state where there are no valid values to emit, in which case the call will loop indefinitely.
///
/// For example:
/// ```dart
/// final variable = randomNonRepeating(10, randomInt());
/// final value = variable.next;  // the following 10 calls to next will not return value
///
/// randomNonRepeating(0, randomInt())  // passing 0 as a length leaves the base variable unmodified
/// ```
RandomVariable<T> randomNonRepeating<T>(int nonRepeatingLength, RandomVariable<T> baseVariable) {
  assert(nonRepeatingLength != null);
  assert(nonRepeatingLength >= 0);
  assert(baseVariable != null);
  if (nonRepeatingLength == 0) return baseVariable;
  return _NonRepeatingVariable(baseVariable, nonRepeatingLength);
}

class _CustomRandom<T> implements RandomVariable<T> {
  final T Function() factory;

  _CustomRandom(this.factory) : assert(factory != null);

  @override
  T get next => factory();
}

class _BaseRandomInt implements RandomVariable<int> {
  final Random _random;
  final int _max;
  final int _offset;

  _BaseRandomInt({int seed, bool secure = false, int max, int offset})
      : _random = secure ? Random.secure() : Random(seed),
        _offset = offset,
        _max = max,
        assert(max > 0),
        assert(offset != null),
        assert(secure == false || seed == null);

  @override
  int get next => _random.nextInt(_max) + _offset;
}

class _BaseRandomDouble implements RandomVariable<double> {
  final Random _random;

  _BaseRandomDouble({int seed, bool secure = false})
      : _random = secure ? Random.secure() : Random(seed),
        assert(secure == false || seed == null);

  @override
  double get next => _random.nextDouble();
}

class _BaseRandomBool implements RandomVariable<bool> {
  final Random _random;

  _BaseRandomBool({int seed, bool secure = false})
      : _random = secure ? Random.secure() : Random(seed),
        assert(secure == false || seed == null);

  @override
  bool get next => _random.nextBool();
}

class _MappedRandomVariable<T, R> extends RandomVariable<R> {
  final R Function(T) mapper;

  final RandomVariable<T> base;

  _MappedRandomVariable(this.mapper, this.base);

  @override
  R get next => mapper(base.next);
}

class _RandomizedList<T> extends RandomVariable<List<T>> {
  final List<T> _list;
  final Random _random;

  _RandomizedList(List<T> list, {int seed, bool secure})
      : _random = secure ? Random.secure() : Random(seed),
        assert(list != null),
        _list = List.of(list),
        assert(secure == false || seed == null);

  @override
  List<T> get next => List.of(_list)..shuffle(_random);
}

/// A wrapper for a [RandomVariable] that caches [depth] calls to [next], yielding them in the order they were generated
class PrecachedRandomVariable<T> extends RandomVariable<T> {
  /// The wrapped variable
  final RandomVariable<T> variable;

  int _depth;
  final Queue<T> _queue = Queue.from([]);

  /// Produces a [PrecachedRandomVariable] that wraps [variable]
  ///
  /// [variable] and [depth] must be non null
  PrecachedRandomVariable(this.variable, {int depth = 10}) {
    assert(variable != null);
    this.depth = depth;
  }

  /// Returns the current queue depth target
  ///
  /// Note that this value represents the lower bounds for the number of items actually in the queue, since increasing the [depth] and then decreasing it does not discard the additionally generated values, since this would break the consistent ordering
  ///
  /// For example:
  /// ```dart
  /// final variable = PrecachedRandomVariable(randomInt(), depth: 5);
  /// // 'next' has been called 5 times
  /// variable.depth  // returns 5
  /// variable.depth = 20
  /// // 'next' has now been called 20 times
  /// ```
  int get depth => _depth;

  /// Sets the queue depth
  ///
  /// If the new [depth] is larger than the previous value, [next] will be populated to fill the queue until the depth requirement is met.
  /// If the new [depth] is smaller than the previous value, the queue size will not change
  set depth(int depth) {
    assert(depth != null);
    assert(depth >= 0);
    _depth = depth;
    _fillQueue();
  }

  /// Returns the next value from the variable
  ///
  /// If the cache contains any values, the first is returned. Otherwise, a new value is generated
  ///
  /// For example:
  /// ```dart
  /// final variable = PrecachedRandomVariable(randomInt());
  /// variable  // returns a random int
  /// ```
  @override
  T get next {
    _fillQueue();
    if (_queue.isEmpty) return variable.next;

    final value = _queue.removeFirst();
    _fillQueue();
    return value;
  }

  void _fillQueue() {
    if (_queue.length == _depth) return;

    while (_queue.length < _depth) {
      _queue.add(variable.next);
    }
  }
}

class _MarkovVariable<T> extends RandomVariable<T> {
  final T Function(T) _builder;
  T _previous;

  _MarkovVariable(this._builder, {T previous}) : _previous = previous;

  @override
  T get next {
    final value = _builder(_previous);
    _previous = value;
    return value;
  }
}

class _RandomListItem<T> extends RandomVariable<T> {
  final List<T> _items;
  final RandomVariable<int> _index;

  _RandomListItem(List<T> items, {int seed, bool secure = false})
      : assert(items != null),
        assert(items.isNotEmpty),
        _items = List.unmodifiable(items),
        _index = randomInt(max: items.length, seed: seed, secure: secure);

  @override
  T get next => _items[_index.next];
}

/// Produces a [RandomVariable] that returns values with weighted probabilities
///
/// For example:
/// ```dart
/// final weights = <String, num>{
///   "hello": 1,
///   "world": 2,
/// };
///
/// final variable = WeightedVariable(weights);
/// variable.next  // 1/3 chance to return "hello", 2/3 chance to return "world"
/// ```
class WeightedVariable<T> extends RandomVariable<T> {
  /// The weights that describe the distribution that this variable follows
  final Map<T, num> weights;
  final num _totalWeight;
  final RandomVariable<double> _variable;

  WeightedVariable(this.weights)
      : assert(weights != null),
        assert(weights.isNotEmpty),
        assert(weights.values.every((element) => !element.isNegative)),
        _totalWeight = weights.values.reduce((a, b) => a + b),
        assert(weights.values.reduce((a, b) => a + b) > 0),
        _variable = randomDouble();

  @override
  T get next {
    final test = _variable.next * _totalWeight;
    var start = 0.0;
    var end = 0.0;

    T lastValue;
    for (final entry in weights.entries) {
      final value = entry.value;
      final key = entry.key;

      start = end;
      end += value;
      if (_between(start, end, test)) {
        return key;
      }
      lastValue = key;
    }

    return lastValue;
  }

  bool _between(num x, num y, num test) {
    if (test < x) return false;
    if (test >= y) return false;
    return true;
  }
}

class _NonRepeatingVariable<T> extends RandomVariable<T> {
  final RandomVariable<T> _base;
  final int _nonRepeatLength;

  final List<T> _values = [];

  _NonRepeatingVariable(this._base, this._nonRepeatLength);

  @override
  T get next {
    while (true) {
      final value = _base.next;
      if (!_values.contains(value)) {
        _values.insert(0, value);
        _trimQueue();
        return value;
      }
    }
  }

  void _trimQueue() => _values.length = min(_values.length, _nonRepeatLength);
}
