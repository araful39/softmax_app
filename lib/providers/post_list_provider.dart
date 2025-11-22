// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:softmax_app/api/api_service.dart';
// import 'package:softmax_app/model/post_list_model.dart';


// class PostListProvider with ChangeNotifier {
//   final StreamController<PosListModel?> _postStreamController =
//       StreamController<PosListModel?>.broadcast();

//   Stream<PosListModel?> get postStream => _postStreamController.stream;

//   Future<void> fetchPosts() async {
//     try {
//       final response = await ApiService.get("/posts", query: {"limit": 10});

//       final data = PosListModel.fromJson(response);

//       _postStreamController.add(data);
//     } catch (e) {
//       _postStreamController.addError(e.toString());
//     }
//   }

//   @override
//   void dispose() {
//     _postStreamController.close();
//     super.dispose();
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:softmax_app/api/api_service.dart';
import 'package:softmax_app/model/post_list_model.dart';

class PostListProvider extends ChangeNotifier {
  final StreamController<PosListModel?> _postController =
      StreamController.broadcast();

  Stream<PosListModel?> get postStream => _postController.stream;

  List<Posts> allPosts = [];
  int skip = 0;
  final int limit = 20;

  bool isLoadingMore = false;
  bool hasMore = true;

  String searchQuery = "";

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      skip = 0;
      hasMore = true;
      allPosts.clear();
    }

    if (!hasMore) return;

    try {
      final data = await ApiService.get("/posts", query: {
        "limit": limit,
        "skip": skip,
        if (searchQuery.isNotEmpty) "q": searchQuery,
      });

      final model = PosListModel.fromJson(data);

      if (refresh) {
        allPosts = model.posts!;
      } else {
        allPosts.addAll(model.posts!);
      }

      skip += limit;
      if (model.posts!.length < limit) {
        hasMore = false;
      }

      _postController.sink.add(PosListModel(posts: allPosts));
    } catch (e) {
      _postController.sink.addError(e.toString());
    }
  }

  void loadMore() {
    if (!isLoadingMore && hasMore) {
      isLoadingMore = true;
      fetchPosts().then((_) {
        isLoadingMore = false;
      });
    }
  }

  Future<void> refreshPosts() async {
    await fetchPosts(refresh: true);
  }

  void searchPosts(String query) {
    searchQuery = query;
    fetchPosts(refresh: true);
  }

  @override
  void dispose() {
    _postController.close();
    super.dispose();
  }
}
