import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/users/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _users = data.map((json) => User.fromJson(json)).toList();
      } else {
        _error = 'Erreur lors du chargement des utilisateurs';
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createUser({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String role,
  }) async {
    try {
      final response = await ApiService.post('/users/', {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'role': role,
      });

      if (response.statusCode == 201) {
        await fetchUsers(); // Recharger la liste
        return true;
      } else {
        _error = 'Erreur lors de la création: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int userId, {
    required String username,
    required String email,
  }) async {
    try {
      final response = await ApiService.put('/users/$userId/', {
        'username': username,
        'email': email,
      });

      if (response.statusCode == 200) {
        await fetchUsers(); // Recharger la liste
        return true;
      } else {
        _error = 'Erreur lors de la modification: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserRole(int userId, String newRole) async {
    try {
      final response = await ApiService.put('/users/$userId/update_role/', {
        'role': newRole,
      });

      if (response.statusCode == 200) {
        await fetchUsers(); // Recharger la liste
        return true;
      } else {
        _error = 'Erreur lors du changement de rôle: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateUser(int userId) async {
    try {
      final response = await ApiService.post('/users/$userId/activate/', {});

      if (response.statusCode == 200) {
        await fetchUsers(); // Recharger la liste
        return true;
      } else {
        _error = 'Erreur lors de l\'activation: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateUser(int userId) async {
    try {
      final response = await ApiService.post('/users/$userId/deactivate/', {});

      if (response.statusCode == 200) {
        await fetchUsers(); // Recharger la liste
        return true;
      } else {
        _error = 'Erreur lors de la désactivation: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final response = await ApiService.delete('/users/$userId/');

      if (response.statusCode == 204) {
        await fetchUsers(); // Recharger la liste
        return true;
      } else {
        _error = 'Erreur lors de la suppression: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  User? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  List<User> getActiveUsers() {
    return _users.where((user) => user.isActive).toList();
  }
} 