import 'either.dart';

/// A [Result<T>] represents either a value of type [T], or an error of type `dynamic`.
/// The error state can be queried with [hasError] and [hasValue].
/// Operations can be chained together with [map], storing any errors. Errors can be recovered from with [resolveErrors].
/// This class shares similarities with [Either].
///
/// For example, consider a login api that returns a [Result]:
/// ```dart
/// final login = () { ... }
/// final handleUser = (user) { ... }
/// final handleError = (error) { ... }
///
/// final Result<User> result = login();
/// if (result.hasValue) {
///   final user = result.value;
///   handleUser(user);
/// } else {
///   final error = result.error;
///   handleError(error);
/// }
/// ```
/// This can be written more concisely as:
/// ```dart
/// login().onValue(handleUser).onError(handleError);
/// ```
class Result<T> {

  /// Follows the Haskell convention of denoting the success state with the right, since "right" == "correct"
  final Either<dynamic, T> _value;

  /// Returns the wrapped value if one exists, returns null if the result represents an error
  T get value => _value.right;

  /// Returns the current error, if present, or null otherwise.
  dynamic get error => null;

  /// Calls a function if a value is present, returning `this`
  ///
  /// If the [Result] is in an error state, nothing will happen
  /// Allows for convenient chaining with [onError].
  ///
  /// For example:
  /// ```dart
  /// final result = Result.success("hello");
  /// result.onValue(print);  // prints "hello"
  ///
  /// final error = Result.error(Exception());
  /// error.onValue(print);  // does nothing
  /// ```
  Result<T> onValue(Function(T) onValue) {
    if (hasValue) onValue(value);
    return this;
  }

  /// Calls a function if an error exists, returning 'this'
  ///
  /// If the [Result] has a value, nothing will happen.
  /// Allows for convenient chaining with [onValue].
  ///
  /// For example:
  /// ```dart
  /// final result = Result.success("hello");
  /// result.onError(print);  // does nothing
  ///
  /// final error = Result.error(Exception());
  /// error.onError((_) => print("an error"));  // prints "an error"
  /// ```
  Result<T> onError(Function(dynamic) onError) {
    if (hasError) onError(error);
    return this;
  }



  /// Returns the contained value if one exists, or throws an error otherwise.
  ///
  /// If one is present, it is returned. If there is no value (i.e. the [Result] is in an error state), the contained error is thrown, unless a non-null [errorBuilder] is provided, in which case, [errorBuilder] is called and the result is thrown. If both [error] and [errorBuilder] are null, an [AssertionError] is thrown.
  ///
  /// For example:
  /// ```dart
  /// Result.success("hello").getOrThrow()  // returns "hello"
  /// Result.error(CustomInnerException()).getOrThrow()  // throws CustomInnerException
  /// Result.error(CustomInnerException()).getOrThrow(() => CustomProvidedException())  // throws CustomProvidedException
  /// ```
  T getOrThrow({Function() errorBuilder}) {
    if (hasValue) return value;

    assert(error != null || errorBuilder != null);
    if (errorBuilder != null) throw errorBuilder();
    throw error;
  }

  /// Returns the contained value if one exists, or a default value otherwise.
  ///
  /// If one is present, it is returned. If there is no value, [valueBuilder] will be called and the result will be returned. If [valueBuilder] is null, an [AssertionError] is thrown.
  ///
  /// For example:
  /// Result.success(10).getOrDefault()  // returns 10
  /// Result<int>.error(Exception()).getOrDefault(valueBuilder: () => 5)  // returns 5
  T getOrDefault({T Function() valueBuilder}) {
    if (hasValue) return value;
    assert (valueBuilder != null);
    return valueBuilder();
  }

  /// Returns `true` if this instance is in an error state, returns `false` otherwise.
  ///
  /// For example:
  /// ```dart
  /// Result.success(5).hasError  // returns false
  /// Result.error(Exception()).hasError  // returns true
  /// ```
  bool get hasError => _value.isLeft;

  /// Returns `true` if this instance has a value (i.e. is not in an error state), returns `false` otherwise.
  ///
  /// For example:
  /// ```dart
  /// Result.success(5).hasValue  // returns true
  /// Result.error(Exception()).hasValue  // returns false
  /// ```
  bool get hasValue => _value.isRight;

  /// Constructor to create a [Result] representing a success, from a known, nullable value.
  Result.success(T value) : _value = Either.right(value);

  /// Constructor to create a [Result] in an error state.
  Result.error(dynamic error) : _value = Either.left(error);

  /// Wraps a [Future] in a [Result]
  ///
  /// If the [Future] completes successfully, [Result.success] is returned, otherwise, [Result.error] is returned.
  ///
  /// For example:
  /// ```dart
  /// final Future<Foo> future = getFutureFromSomewhere();
  /// final resultFuture = Result.fromFuture(future);
  ///
  /// final result = await resultFuture;
  /// result.onValue(handleValue).onError(handleError)
  /// ```
  static Future<Result<T>> fromFuture<T>(Future<T> future) async {
    assert(future != null);
    Result<T> result;
    await future
        .then((value) => result = Result.success(value))
        .catchError((error) => result = Result.error(error));

    return result;
  }

  /// Maps a result with a function.
  ///
  /// If the result is in an error state, the function is not evaluated and the error is returned. If the result has a value, the function is applied and the output is wrapped in a [Result].
  ///
  /// For example:
  /// ```dart
  /// Result.success("hello").map((s) => "$s world")  // returns Result.success("hello world")
  /// Result.error(Exception()).map((s) => "$s world")  // returns Result.error(Exception())
  /// ```
  Result<R> map<R>(R Function(T) mapper) {
    if (hasError) return Result.error(error);
    try {
      return Result.success(mapper(value));
    } catch (error) {
      return Result.error(error);
    }
  }

  /// Attempts to recover a [Result] from an error state.
  ///
  /// [errorResolver] takes a [dynamic] error and attempts to return a [T]. If this succeeds, a [Result] is returned containing this value.
  /// If an error is thrown during the execution of [errorResolver], that error is passed to the returned [Result].
  ///
  /// For example:
  /// ```dart
  /// final int Function(dynamic) errorResolver = (error) {
  ///   if (error is FormatException) return -1;
  ///   throw error;
  /// }
  ///
  /// final Result<int> success = parseIntToResult("123");
  /// success.resolveErrors(errorResolver)  // returns Result<int>.success(123)
  ///
  /// final formatErrorResult = parseIntToResult("not a number");
  /// formatErrorResult.resolveErrors(errorResolver)  // returns Result<int>.error(-1)
  ///
  /// final Result<Foo> otherError = someOtherResultFunctionThatFails();
  /// otherError.resolve(errorResolver)  // returns otherError, leaves unchanged
  /// ```
  Result<T> resolveErrors(T Function(dynamic) errorResolver) {
    if (hasValue) return this;
    assert(errorResolver != null);
    try {
      return Result.success(errorResolver(error));
    } catch (e) {
      return Result.error(e);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Result && runtimeType == other.runtimeType && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

}

