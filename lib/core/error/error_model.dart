class ErrorModel {
  final int status;
  final String errorMessage;
  final String? code;

  ErrorModel({required this.status, required this.errorMessage, this.code});

  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey('error')) {
      final errorData = jsonData['error'];
      return ErrorModel(
        status: jsonData['statusCode'] as int? ?? -1,
        code: errorData['code'] as String?,
        errorMessage:
            errorData['description'] as String? ??
            errorData['message'] as String? ??
            'حدث خطأ غير معروف',
      );
    }

    return ErrorModel(
      status: jsonData['status'] as int? ?? -1,
      errorMessage:
          jsonData['ErrorMessage'] as String? ??
          jsonData['errorMessage'] as String? ??
          jsonData['message'] as String? ??
          'حدث خطأ غير معروف',
    );
  }
}
