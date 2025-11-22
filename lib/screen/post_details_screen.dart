import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:softmax_app/providers/post_details_provider.dart';
import 'package:softmax_app/model/post_details_model.dart';

class PostDetailsScreen extends StatefulWidget {
  final int postId;
  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<PostDetailsProvider>(
        context,
        listen: false,
      ).fetchPostDetails(widget.postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostDetailsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        backgroundColor: Colors.deepPurple,
      ),

      body: StreamBuilder<PostDetailsModel?>(
        stream: provider.detailsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No Data Found"));
          }

          final post = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text(
                  post.title ?? "",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(post.body ?? "", style: const TextStyle(fontSize: 18)),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  children: post.tags!
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.deepPurple.shade100,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "👍 Likes: ${post.reactions?.likes}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "👎 Dislikes: ${post.reactions?.dislikes}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Text(
                      "👁 Views: ${post.views}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
