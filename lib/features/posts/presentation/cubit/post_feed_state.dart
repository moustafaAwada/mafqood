import 'package:equatable/equatable.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

class PostFeedState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<PostItem> posts;
  final String searchQuery;
  final String? error;

  const PostFeedState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.posts = const [],
    this.searchQuery = '',
    this.error,
  });

  PostFeedState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<PostItem>? posts,
    String? searchQuery,
    String? error,
    bool clearError = false,
  }) {
    return PostFeedState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      posts: posts ?? this.posts,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<PostItem> get filteredPosts {
    if (searchQuery.trim().isEmpty) return posts;
    final q = searchQuery.toLowerCase();
    return posts.where((p) {
      final name = (p.userName ?? '').toLowerCase();
      final description = (p.description ?? '').toLowerCase();
      return name.contains(q) || description.contains(q);
    }).toList();
  }

  @override
  List<Object?> get props =>
      [isLoading, isRefreshing, posts, searchQuery, error];
}

