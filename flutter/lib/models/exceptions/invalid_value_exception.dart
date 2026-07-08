class InvalidValueException implements Exception {
  final String message;
  InvalidValueException(this.message);

  @override
  String toString() => 'Invalid value for function: $message';
}
