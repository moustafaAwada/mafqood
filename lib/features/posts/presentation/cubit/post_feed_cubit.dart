import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/domain/repositories/post_repository.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_state.dart';

class PostFeedCubit extends Cubit<PostFeedState> {
  final PostRepository _postRepository;

  PostFeedCubit({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(const PostFeedState());

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    final result = await _postRepository.getPosts(
      pageNumber: 1,
      pageSize: 20,
      searchKey: state.searchQuery.trim().isEmpty ? null : state.searchQuery,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          posts: data.items,
        ),
      ),
    );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> toggleReact({
    required int postId,
    required ReactType reactType,
  }) async {
    final result = await _postRepository.toggleReact(
      postId: postId,
      reactType: reactType,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (counts) {
        final updated = state.posts.map((post) {
          if (post.id != postId) return post;
          return post.copyWith(
            likesCount: counts.likesCount,
            dislikesCount: counts.dislikesCount,
            userReactType: counts.userReactType,
            clearUserReactType: counts.userReactType == null,
          );
        }).toList();
        emit(state.copyWith(posts: updated));
      },
    );
  }

  Future<void> toggleSave({
    required int postId,
    required bool isSaved,
  }) async {
    final result = isSaved
        ? await _postRepository.unSavePost(postId)
        : await _postRepository.savePost(postId);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {
        final updated = state.posts.map((post) {
          if (post.id != postId) return post;
          return post.copyWith(isSaved: !isSaved);
        }).toList();
        emit(state.copyWith(posts: updated));
      },
    );
  }
}

