import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/exceptions.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/data/models/chat_models.dart';
import 'package:mafqood/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;

  ChatRepositoryImpl({required ChatRemoteDataSource remote}) : _remote = remote;

  // ─── Chat Room Operations ───────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedChatRooms>> getChatRooms({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    ChatRoomFilter filter = ChatRoomFilter.all,
  }) async {
    try {
      final result = await _remote.getChatRooms(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchKey: searchKey,
        filter: filter,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatRoomDetailModel>> getChatRoomById(
    int chatRoomId,
  ) async {
    try {
      final result = await _remote.getChatRoomById(chatRoomId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChatRoom(int chatRoomId) async {
    try {
      await _remote.deleteChatRoom(chatRoomId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Message Operations ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedMessages>> getMessages(
    int chatRoomId, {
    int pageNumber = 1,
    int pageSize = 20,
    MessageType? typeFilter,
    DateTime? afterTimestamp,
  }) async {
    try {
      final result = await _remote.getMessages(
        chatRoomId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        typeFilter: typeFilter,
        afterTimestamp: afterTimestamp,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InitiateMessageResponse>> initiateMessage({
    required String clientMessageId,
    required String recipientUserId,
    String? content,
    required MessageType type,
    File? attachment,
  }) async {
    try {
      final result = await _remote.initiateMessage(
        clientMessageId: clientMessageId,
        recipientUserId: recipientUserId,
        content: content,
        type: type,
        attachment: attachment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessagesAsRead(int chatRoomId) async {
    try {
      await _remote.markMessagesAsRead(chatRoomId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage(
    int chatRoomId,
    int messageId,
  ) async {
    try {
      await _remote.deleteMessage(chatRoomId, messageId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
