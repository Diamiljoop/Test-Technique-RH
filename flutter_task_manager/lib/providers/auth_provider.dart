import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _accessToken != null;
  User? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);
      _accessToken = response['access'];
      _refreshToken = response['refresh'];
      ApiService.setToken(_accessToken!);
      // Charger l'utilisateur connecté
      await loadCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final response = await ApiService.get('/users/me/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data);
      }
    } catch (e) {
      // ignore
    }
    notifyListeners();
  }

  Future<bool> refreshTokenMethod() async {
    if (_refreshToken == null) return false;

    try {
      final response = await ApiService.refreshToken(_refreshToken!);
      _accessToken = response['access'];
      ApiService.setToken(_accessToken!);
      notifyListeners();
      return true;
    } catch (e) {
      logout();
      return false;
    }
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _error = null;
    _currentUser = null;
    ApiService.setToken('');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 