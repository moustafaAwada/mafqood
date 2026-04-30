import 'package:flutter_test/flutter_test.dart';

import 'package:mafqood/core/api/result_envelope.dart';

void main() {
  test('ResultEnvelope parses success without data', () {
    final env = ResultEnvelope.fromJson({
      'isSuccess': true,
      'hasData': false,
    });
    expect(env.isSuccess, true);
    expect(env.hasData, false);
    expect(env.data, null);
  });
}
