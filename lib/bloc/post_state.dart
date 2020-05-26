import 'package:equatable/equatable.dart';
import 'package:infinite_list_bloc/models/post.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostFaliure extends PostState {}

class PostSuccess extends PostState {
  final List<Post> posts;
  final bool hasReachedMax;

  const PostSuccess({this.posts, this.hasReachedMax});

  // func to change the members
  PostSuccess copywith({List<Post> posts, bool hasReachedMax}) {
    return PostSuccess(
      posts: posts ?? this.posts, // posts if passed, else posts in object.
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [posts, hasReachedMax];

  @override
  String toString() => 'PostLoaded { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
