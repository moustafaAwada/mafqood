class ErrorModel {
  final int status;
  final String errorMessage;
  final String? code;

  ErrorModel({required this.status, required this.errorMessage, this.code});

  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    // Format 1: Our standard error envelope { "error": { "code": "...", "description": "..." } }
    if (jsonData.containsKey('error') && jsonData['error'] is Map) {
      final errorData = jsonData['error'] as Map<String, dynamic>;
      return ErrorModel(
        status: jsonData['statusCode'] as int? ?? -1,
        code: errorData['code'] as String?,
        errorMessage:
            errorData['description'] as String? ??
            errorData['message'] as String? ??
            'حدث خطأ غير معروف',
      );
    }

    // Format 2: ASP.NET validation errors { "title": "...", "errors": { "Field": ["msg"] } }
    if (jsonData.containsKey('errors') && jsonData['errors'] is Map) {
      final errorsMap = jsonData['errors'] as Map<String, dynamic>;
      final messages = <String>[];
      for (final entry in errorsMap.entries) {
        if (entry.value is List) {
          for (final msg in entry.value as List) {
            messages.add(msg.toString());
          }
        }
      }
      if (messages.isNotEmpty) {
        return ErrorModel(
          status: jsonData['status'] as int? ?? -1,
          errorMessage: messages.join('\n'),
        );
      }
    }

    // Format 3: Flat error fields
    return ErrorModel(
      status: jsonData['status'] as int? ?? -1,
      errorMessage:
          jsonData['ErrorMessage'] as String? ??
          jsonData['errorMessage'] as String? ??
          jsonData['message'] as String? ??
          jsonData['title'] as String? ??
          'حدث خطأ غير معروف',
    );
  }
}

