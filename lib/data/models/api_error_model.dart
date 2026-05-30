class ApiError {
  final int statusCode;
  final dynamic message;
  final String? error;

  String get displayMessage {
    if (message is List) return (message as List).join(', ');
    return message.toString();
  }

  const ApiError({
    required this.statusCode,
    required this.message,
    this.error,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['statusCode'] ?? 500,
      message: json['message'] ?? 'Erreur inconnue',
      error: json['error'],
    );
  }
}
