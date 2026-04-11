import 'package:dio/dio.dart';
import 'package:mafqood/core/error/error_model.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;

  ServerException({required this.errorModel});
}

ErrorModel _parseErrorModel(dynamic data, int? statusCode, String? message) {
  if (data is Map<String, dynamic>) {
    try {
      return ErrorModel.fromJson(data);
    } catch (_) {
      return ErrorModel(
        status: statusCode ?? -1,
        errorMessage: message ?? 'حدث خطأ غير معروف',
      );
    }
  }

  if (data is String && data.isNotEmpty) {
    return ErrorModel(status: statusCode ?? -1, errorMessage: data);
  }

  return ErrorModel(
    status: statusCode ?? -1,
    errorMessage: message ?? 'حدث خطأ غير معروف',
  );
}

void handleDioException(DioException e) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;
  final message = e.message;

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      throw ServerException(
        errorModel: _parseErrorModel(data, statusCode, message),
      );
    case DioExceptionType.badResponse:
      throw ServerException(
        errorModel: _parseErrorModel(data, statusCode, message),
      );
  }
}
