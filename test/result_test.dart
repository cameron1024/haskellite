
import 'package:haskellite/haskellite.dart';
import 'package:test/test.dart';


const _string = 'Hello';
final _stringMapper = (String s) => s + ' world';
final _mappedString = _stringMapper(_string);
final _success = Result.success(_string);
final _error = Result<String>.error(Exception('message'));

void main() {
  test('result constructor should behave as expected', () {
    expect(_success.hasValue, isTrue);
    expect(_success.hasError, isFalse);
    expect(_success.value, equals(_string));
    expect(_success.error, isNull);
    
    expect(_error.hasValue, isFalse);
    expect(_error.hasError, isTrue);
    expect(_error.value, isNull);
    expect(_error.error, isA<Exception>());
  });
  
  test('result from future should correctly handle success and error states', () async {
    final fromValue = await Result.fromFuture(Future.value(_string));
    expect(fromValue.hasValue, isTrue);
    expect(fromValue.value, equals(_string));

    final fromError = await Result.fromFuture<String>(Future.error(Exception('message')));
    expect(fromError.hasError, isTrue);
    expect(fromError.value, null);
    expect(fromError.error, isA<Exception>());
  });
  
  test('map should correctly map values', () {
    expect(_success.map(_stringMapper), equals(Result.success(_mappedString)));
    expect(_error.map(_stringMapper), equals(_error));
  });

  test('getOrThrow should return a value if one is present', () {
    expect(_success.getOrThrow(), equals(_success.value));
  });

  test('getOrThrow should throw the stored error if no value is present', () {
    expect(() => _error.getOrThrow(), throwsA(isA<Exception>()));
  });

  test('getOrThrow should throw the provided error if one exists', () {
    expect(() => _error.getOrThrow(errorBuilder: () => MissingValueException('hello')), throwsA(isA<MissingValueException>()));
  });

  test('getOrDefault should return a value if one is present', () {
    expect(_success.getOrDefault(), equals(_string));
  });

  test('getOrDefault should return the provided default value if no value is present', () {
    expect(_error.getOrDefault(valueBuilder: () => 'hello'), equals('hello'));
  });

  test('getOrDefault should throw an error if no value or valueBuilder present', () {
    expect(() => _error.getOrDefault(), throwsA(isA<AssertionError>()));
  });

  test('resolveErrors should attempt to resolve errors', () {
    final errorResolver = (error) => 'resolved';
    expect(_error.resolveErrors(errorResolver), equals(Result.success('resolved')));
  });

  test('resolveErrors should not modify a success state', () {
    final errorResolver = (error) => 'resolved';
    expect(_success.resolveErrors(errorResolver), equals(_success));
  });

  test('resolveErrors should fail if null on a failed state', () {
    expect(() => _error.resolveErrors(null), throwsA(isA<AssertionError>()));
    expect(() => _success.resolveErrors(null), isNot(throwsA(anything)));
  });

  test('onValue and onError should return the same instance', () {
    final result = _success;

    expect(result.onError((_) => null), same(result));
    expect(result.onValue((_) => null), same(result));

  });
  
  
}