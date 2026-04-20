import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/exceptions.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remote;

  PostRepositoryImpl({required PostRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, PaginatedResult<PostItem>>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  }) async {
    try {
      final result = await _remote.getPosts(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchKey: searchKey,
        type: type,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReactCounts>> toggleReact({
    required int postId,
    required ReactType reactType,
  }) async {
    try {
      final result = await _remote.toggleReact(
        postId: postId,
        reactType: reactType,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createPost({
    required String description,
    required int type,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
  }) async {
    try {
      await _remote.createPost(
        description: description,
        type: type,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        imagePath: imagePath,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePost(int postId) async {
    try {
      await _remote.savePost(postId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unSavePost(int postId) async {
    try {
      await _remote.unSavePost(postId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
