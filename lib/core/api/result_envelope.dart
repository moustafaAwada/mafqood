import 'package:mafqood/core/error/error_model.dart';

/// Unified API response envelope (Result Pattern).
///
/// Backend contract:
/// - Success with data:    { "isSuccess": true,  "hasData": true,  "data": ... }
/// - Success without data: { "isSuccess": true,  "hasData": false }
/// - Failure:              { "isSuccess": false, "statusCode": 400, "error": { "code": "...", "description": "..." } }
class ResultEnvelope {
  final bool isSuccess;
  final bool hasData;
  final Object? data;
  final int? statusCode;
  final ErrorModel? error;

  const ResultEnvelope({
    required this.isSuccess,
    required this.hasData,
    this.data,
    this.statusCode,
    this.error,
  });

  factory ResultEnvelope.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['isSuccess'] == true;
    final hasData = json['hasData'] == true;

    // On failures, the backend provides statusCode + error object.
    final error = isSuccess ? null : ErrorModel.fromJson(json);

    return ResultEnvelope(
      isSuccess: isSuccess,
      hasData: hasData,
      data: json['data'],
      statusCode: json['statusCode'] as int? ?? json['status'] as int?,
      error: error,
    );
  }

  static ResultEnvelope? tryParse(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return ResultEnvelope.fromJson(raw);
    }
    if (raw is Map) {
      return ResultEnvelope.fromJson(raw.cast<String, dynamic>());
    }
    return null;
  }

  Map<String, dynamic>? dataAsMapOrNull() {
    final d = data;
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return d.cast<String, dynamic>();
    return null;
  }
}

