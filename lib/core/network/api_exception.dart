/// Typed exception carrying a user-friendly message plus optional
/// field-level validation errors (Laravel `errors` bag) and an HTTP status.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.errors = const {},
  });

  /// True when the backend rejected the request with validation errors (422).
  bool get hasValidationErrors => errors.isNotEmpty;

  /// True when auth failed / expired (401) or forbidden (403).
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// True when rate-limited (429).
  bool get isRateLimited => statusCode == 429;

  /// First validation message for a field, if any.
  String? firstError(String field) {
    final list = errors[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
