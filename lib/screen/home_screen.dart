import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softmax_app/providers/post_list_provider.dart';
import 'package:softmax_app/screen/post_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.example.device_info/methods');
  String _deviceInfo = 'Press the button to get device info';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<PostListProvider>(context, listen: false).fetchPosts(),
    );

    _scrollController.addListener(() {
      final provider = Provider.of<PostListProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          provider.hasMore &&
          !provider.isLoadingMore &&
          provider.searchQuery.isEmpty) {
        // Only load more when not searching
        provider.loadMore();
      }
    });
  }

  void _onSearchChanged(String query) {
    final provider = Provider.of<PostListProvider>(context, listen: false);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      provider.searchPosts(query);
    });
  }

  Future<void> _getDeviceInfo() async {
    String deviceInfo;
    try {
      final String result = await platform.invokeMethod('getAllDeviceInfo');
      deviceInfo = result;
    } on PlatformException catch (e) {
      deviceInfo = "Failed to get device info: '${e.message}'.";
    }

    if (!mounted) return;

    setState(() => _deviceInfo = deviceInfo);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(deviceInfo: _deviceInfo),
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getDeviceInfo,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.refresh),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search posts...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Consumer<PostListProvider>(
              builder: (context, provider, _) {
                final posts = provider.filteredPosts;
                final showLoading =
                    provider.searchQuery.isEmpty && provider.hasMore;

                if (provider.isLoading && posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (posts.isEmpty) {
                  return const Center(child: Text("No posts found"));
                }

                return RefreshIndicator(
                  onRefresh: provider.refreshPosts,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: posts.length + (showLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == posts.length && showLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PostDetailsScreen(postId: post.id!),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          child: ListTile(
                            title: Text(
                              post.title ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              post.body ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("👍 ${post.reactions?.likes ?? 0}"),
                                Text("👁 ${post.views ?? 0}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key, required this.deviceInfo});
  final String deviceInfo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              deviceInfo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
