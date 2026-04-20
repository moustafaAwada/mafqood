import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mafqood/core/api/api_consumer.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:mafqood/features/posts/data/models/post_models.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiConsumer _api;

  PostRemoteDataSourceImpl({required ApiConsumer api}) : _api = api;

  int? _typeToInt(PostType? type) {
    if (type == null) return null;
    return type == PostType.lost ? 0 : 1;
  }

  int _reactTypeToInt(ReactType type) => type == ReactType.like ? 0 : 1;

  @override
  Future<PaginatedResult<PostItem>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  }) async {
    final response = await _api.get(
      EndPoints.posts,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchKey != null && searchKey.trim().isNotEmpty)
          'searchKey': searchKey.trim(),
        if (_typeToInt(type) != null) 'type': _typeToInt(type),
      },
    );

    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return PaginatedResultModel<PostItem>.fromJson(
      data,
      (item) => PostItemModel.fromJson(item),
    );
  }

  @override
  Future<ReactCounts> getReactCounts(int postId) async {
    final response = await _api.get(EndPoints.postReactCounts(postId));
    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ReactCountsModel.fromJson(data);
  }

  @override
  Future<ReactCounts> toggleReact({
    required int postId,
    required ReactType reactType,
  }) async {
    final response = await _api.post(
      EndPoints.postReacts(postId),
      data: {'postId': postId, 'reactType': _reactTypeToInt(reactType)},
    );
    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ReactCountsModel.fromJson(data);
  }

  @override
  Future<void> createPost({
    required String description,
    required int type,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
  }) async {
    final request = <String, dynamic>{
      'description': description,
      'type': type,
      'latitude': ?latitude,
      'longitude': ?longitude,
      if (locationName != null && locationName.trim().isNotEmpty)
        'location': locationName.trim(),
    };

    final bool hasImage = imagePath != null && imagePath.trim().isNotEmpty;

    await _api.post(
      EndPoints.posts,
      data: hasImage
          ? FormData.fromMap({
              ...request,
              'image': MultipartFile.fromFileSync(
                imagePath,
                filename: imagePath.split(Platform.pathSeparator).last,
              ),
            })
          : request,
      isFormData: hasImage,
    );
  }

  @override
  Future<void> savePost(int postId) async {
    await _api.post(EndPoints.savedPosts, data: {'postId': postId});
  }

  @override
  Future<void> unSavePost(int postId) async {
    await _api.delete(EndPoints.savedPosts, data: {'postId': postId});
  }
}
