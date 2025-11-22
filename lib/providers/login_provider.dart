import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../model/log_in_model.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  LogInModel? user;
  String errorMessage = '';

  Future<bool> login(String username, String password) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        "username": username,
        "password": password,
      });

      isLoading = false;

      if (response['accessToken'] != null) {
        user = LogInModel.fromJson(response);
        ApiService.setToken(user!.accessToken!);
        notifyListeners();
        return true;
      } else {
        errorMessage = response['msg'] ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      isLoading = false;
      errorMessage = ApiService.handleError(e);
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void logout() {
    user = null;
    ApiService.clearToken();
    notifyListeners();
  }
}
