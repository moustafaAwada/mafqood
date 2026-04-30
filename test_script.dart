import 'package:dio/dio.dart';

void main() {
  try {
    final fd = FormData.fromMap({
      'Lat': null,
      'Long': null,
      'Text': 'hello',
    });
    print('SUCCESS! Form fields: ${fd.fields}');
  } catch (e) {
    print('ERROR: $e');
  }
}
