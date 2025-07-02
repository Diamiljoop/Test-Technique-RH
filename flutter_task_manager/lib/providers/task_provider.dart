import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/taches/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _tasks = data.map((json) => Task.fromJson(json)).toList();
      } else {
        _error = 'Erreur lors du chargement des tâches';
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTask(String titre, String description, String statut, int? assigneeId, int projetId) async {
    try {
      final taskData = {
        'titre': titre,
        'description': description,
        'statut': statut,
        'projet_id': projetId,
      };
      
      if (assigneeId != null) {
        taskData['assignee_id'] = assigneeId;
      }

      final response = await ApiService.post('/taches/', taskData);
      if (response.statusCode == 201) {
        await fetchTasks(); // Recharger la liste
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

  Future<bool> updateTask(int id, String titre, String description, String statut, int? assigneeId, int projetId) async {
    try {
      final taskData = {
        'titre': titre,
        'description': description,
        'statut': statut,
        'projet_id': projetId,
      };
      
      if (assigneeId != null) {
        taskData['assignee_id'] = assigneeId;
      }

      final response = await ApiService.put('/taches/$id/', taskData);
      if (response.statusCode == 200) {
        await fetchTasks(); // Recharger la liste
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

  Future<bool> deleteTask(int id) async {
    try {
      final response = await ApiService.delete('/taches/$id/');
      if (response.statusCode == 204) {
        await fetchTasks(); // Recharger la liste
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

  List<Task> getTasksByStatus(String status) {
    return _tasks.where((task) => task.statut == status).toList();
  }

  List<Task> getTasksByAssignee(int assigneeId) {
    return _tasks.where((task) => task.assigneeId == assigneeId).toList();
  }
} 