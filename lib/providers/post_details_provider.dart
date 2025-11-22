import 'dart:async';
import 'package:flutter/material.dart';
import 'package:softmax_app/api/api_service.dart';
import 'package:softmax_app/model/post_details_model.dart';

class PostDetailsProvider extends ChangeNotifier {
  final StreamController<PostDetailsModel?> _detailsController =
      StreamController.broadcast();

  Stream<PostDetailsModel?> get detailsStream => _detailsController.stream;

  Future<void> fetchPostDetails(int id) async {
    try {
      final data = await ApiService.get("/posts/$id");
      final model = PostDetailsModel.fromJson(data);
      _detailsController.sink.add(model);
    } catch (e) {
      _detailsController.sink.addError(e.toString());
    }
  }

  @override
  void dispose() {
    _detailsController.close();
    super.dispose();
  }
}
