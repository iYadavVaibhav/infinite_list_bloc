import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:infinite_list_bloc/bloc/post_event.dart';
import 'package:infinite_list_bloc/bloc/post_state.dart';
import 'package:infinite_list_bloc/models/post.dart';
import 'package:rxdart/rxdart.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  get initialState => PostInitial();

  @override
  Stream<Transition<PostEvent, PostState>> transformEvents(
    Stream<PostEvent> events,
    TransitionFunction<PostEvent, PostState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    final currentState = state; //from Bloc class

    if (event is PostFetched && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostInitial) {
          final posts = await _fetchPosts(0, 20);
          yield PostSuccess(posts: posts, hasReachedMax: false);
          return;
        }
        if (currentState is PostSuccess) {
          final posts = await _fetchPosts(currentState.posts.length, 20);
          if (posts.isEmpty) {
            yield currentState.copywith(hasReachedMax: true);
          } else {
            yield PostSuccess(
              posts: currentState.posts + posts,
              hasReachedMax: false,
            );
          }
        }
      } catch (_) {
        yield PostFaliure();
      }
    }
  }

  bool _hasReachedMax(PostState state) {
    return state is PostSuccess && state.hasReachedMax;
  }

  _fetchPosts(int start, int limit) async {
    // String url = 'http://iyadavvaibhav.pythonanywhere.com/todo/api/v1.0/tasks'
    String url =
        'https://jsonplaceholder.typicode.com/posts?_start=$start&_limit=$limit';
    final response = await httpClient.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;

      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          body: rawPost['body'],
          title: rawPost['title'],
        );
      }).toList();
    } else {
      throw Exception('Error fetching post');
    }
  }
}
