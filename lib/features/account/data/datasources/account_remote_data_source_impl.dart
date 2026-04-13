import 'package:mafqood/core/api/api_consumer.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/account/data/datasources/account_remote_data_source.dart';
import 'package:mafqood/features/account/data/models/account_request_models.dart';

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiConsumer _api;

  AccountRemoteDataSourceImpl({required ApiConsumer api}) : _api = api;

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final request = UpdateLocationRequest(
      latitude: latitude,
      longitude: longitude,
    );
    await _api.put(
      EndPoints.updateLocation,
      data: request.toJson(),
    );
  }
}
