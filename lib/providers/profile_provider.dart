import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:softmax_app/api/api_service.dart';
import 'package:softmax_app/model/profile_model.dart';


class ProfileProvider with ChangeNotifier {
  final StreamController<ProfiileModel?> _profileController =
      StreamController<ProfiileModel?>.broadcast();

  Stream<ProfiileModel?> get profileStream => _profileController.stream;

  ProfiileModel? userProfile;

  Future<void> fetchProfile() async {
    try {
      final response = await ApiService.get("/auth/me");
      userProfile = ProfiileModel.fromJson(response);
      _profileController.sink.add(userProfile);
    } catch (e) {
      _profileController.sink.addError(e.toString());
    }
  }

  @override
  void dispose() {
    _profileController.close();
    super.dispose();
  }
}
