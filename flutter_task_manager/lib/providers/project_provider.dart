import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/projets/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _projects = data.map((json) => Project.fromJson(json)).toList();
      } else {
        _error = 'Erreur lors du chargement des projets';
      }
    } catch (e) {
      _error = 'Erreur de connexion: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProject(String nom, String description) async {
    try {
      final projectData = {
        'nom': nom,
        'description': description,
      };

      final response = await ApiService.post('/projets/', projectData);
      if (response.statusCode == 201) {
        await fetchProjects(); // Recharger la liste
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

  Future<bool> updateProject(int id, String nom, String description) async {
    try {
      final projectData = {
        'nom': nom,
        'description': description,
      };

      final response = await ApiService.put('/projets/$id/', projectData);
      if (response.statusCode == 200) {
        await fetchProjects(); // Recharger la liste
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

  Future<bool> deleteProject(int id) async {
    try {
      final response = await ApiService.delete('/projets/$id/');
      if (response.statusCode == 204) {
        await fetchProjects(); // Recharger la liste
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

  Project? getProjectById(int id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
} 