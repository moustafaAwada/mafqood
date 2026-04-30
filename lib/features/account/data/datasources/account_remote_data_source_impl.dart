import 'dart:io';
import 'package:mafqood/core/api/api_consumer.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:dio/dio.dart';
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

  @override
  Future<dynamic> updateUserInfo({required String name, required String phoneNumber}) async {
    final response = await _api.put(
      EndPoints.updateInfo,
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
      },
    );
    return response;
  }

  @override
  Future<dynamic> updateProfilePicture(File image) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });
    final response = await _api.put(
      EndPoints.updateProfilePicture,
      data: formData,
      isFormData: true,
    );
    return response;
  }

  @override
  Future<dynamic> getCurrentUserProfile() async {
    final response = await _api.get(EndPoints.me);
    return response;
  }
}
