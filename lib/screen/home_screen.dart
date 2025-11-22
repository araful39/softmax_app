import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softmax_app/model/post_list_model.dart';
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

  Future<void> _getDeviceInfo() async {
    String deviceInfo;
    try {
      final String result = await platform.invokeMethod('getAllDeviceInfo');
      deviceInfo = result;
    } on PlatformException catch (e) {
      deviceInfo = "Failed to get device info: '${e.message}'.";
    }

    setState(() {
      _deviceInfo = deviceInfo;
    });

    // Show success dialog after getting info
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(deviceInfo: _deviceInfo),
    );

    // Auto close after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<PostListProvider>(context, listen: false).fetchPosts());

    _scrollController.addListener(() {
      final provider =
          Provider.of<PostListProvider>(context, listen: false);

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      final provider = Provider.of<PostListProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post List (StreamBuilder)"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getDeviceInfo,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.refresh),
      ),
 body: Column(
        children: [
          // 🔍 Search Box
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
              onChanged: provider.searchPosts,
            ),
          ),

          Expanded(
            child: StreamBuilder<PosListModel?>(
              stream: provider.postStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.posts == null) {
                  return const Center(child: Text("No Data Found"));
                }

                final posts = snapshot.data!.posts!;

                return RefreshIndicator(
                  onRefresh: provider.refreshPosts,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        return provider.hasMore
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox();
                      }  

                      final post = posts[index];

                      return GestureDetector(
                        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PostDetailsScreen(postId: post.id!),
    ),
  );
},

                        child: Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              post.title ?? "",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              post.body ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              children: [
                                Text("👍 ${post.reactions?.likes}"),
                                Text("👁 ${post.views}"),
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
}
// Beautiful Success Dialog Widget
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
