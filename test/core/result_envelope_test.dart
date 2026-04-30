import 'package:flutter_test/flutter_test.dart';
import 'package:mafqood/core/api/result_envelope.dart';

void main() {
  group('ResultEnvelope', () {
    test('parses success with data', () {
      final env = ResultEnvelope.fromJson({
        'isSuccess': true,
        'hasData': true,
        'data': {'profilePictureUrl': 'https://example.com/a.jpg'},
      });
      expect(env.isSuccess, true);
      expect(env.hasData, true);
      expect(env.dataAsMapOrNull()?['profilePictureUrl'], 'https://example.com/a.jpg');
    });

    test('parses failure with error envelope', () {
      final env = ResultEnvelope.fromJson({
        'isSuccess': false,
        'statusCode': 400,
        'error': {
          'code': 'Validation',
          'description': 'Name is required.',
        },
      });
      expect(env.isSuccess, false);
      expect(env.error?.code, 'Validation');
      expect(env.error?.errorMessage, 'Name is required.');
    });
  });
}

