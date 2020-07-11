
/// Represents an exception when a value is requested when one doesn't exist
class MissingValueException implements Exception {
  final String message;
  MissingValueException(this.message);
}