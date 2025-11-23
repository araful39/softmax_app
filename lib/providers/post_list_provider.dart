import 'package:flutter/material.dart';
import 'package:softmax_app/api/api_service.dart';
import 'package:softmax_app/model/post_list_model.dart';

class PostListProvider extends ChangeNotifier {
  List<Posts> allPosts = []; // All posts fetched from API
  List<Posts> filteredPosts = []; // Filtered posts for search

  int skip = 0;
  final int limit = 20;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  String searchQuery = "";

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      skip = 0;
      hasMore = true;
      allPosts.clear();
      filteredPosts.clear();
      notifyListeners();
    }

    if (!hasMore || isLoadingMore) return;

    isLoadingMore = true;
    isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.get(
        "/posts",
        query: {"limit": limit, "skip": skip},
      );

      final model = PosListModel.fromJson(data);

      allPosts.addAll(model.posts ?? []);
      skip += limit;

      if ((model.posts ?? []).length < limit) hasMore = false;

      _applySearch(); // Apply search filter to update filteredPosts
    } catch (e) {
      // handle error
    } finally {
      isLoadingMore = false;
      isLoading = false;
      notifyListeners();
    }
  }

  void loadMore() {
    if (!isLoadingMore && hasMore) fetchPosts();
  }

  Future<void> refreshPosts() async => fetchPosts(refresh: true);

  void searchPosts(String query) {
    searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (searchQuery.isEmpty) {
      filteredPosts = List.from(allPosts);
    } else {
      filteredPosts = allPosts
          .where(
            (post) =>
                (post.title ?? "").toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (post.body ?? "").toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }
}
