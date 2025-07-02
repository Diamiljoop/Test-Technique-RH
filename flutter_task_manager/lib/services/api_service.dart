import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/project.dart';
import '../models/task.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Pour l'émulateur Android
  static const String baseUrl = 'http://localhost:8000/api'; // Pour iOS/Web
  // static const String baseUrl = 'http://192.168.1.XXX:8000/api'; // Pour appareil physique
  
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // ==================== MÉTHODES GÉNÉRIQUES ====================
  
  static Future<http.Response> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return response;
    } catch (e) {
      throw Exception('Erreur GET $endpoint: $e');
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Erreur POST $endpoint: $e');
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Erreur PUT $endpoint: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return response;
    } catch (e) {
      throw Exception('Erreur DELETE $endpoint: $e');
    }
  }

  // ==================== AUTHENTIFICATION ====================
  
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access'];
        return data;
      } else {
        throw Exception('Échec de connexion: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access'];
        return data;
      } else {
        throw Exception('Échec du refresh token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur refresh token: $e');
    }
  }

  // ==================== UTILISATEURS ====================
  
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Échec récupération utilisateurs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur récupération utilisateurs: $e');
    }
  }

  static Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: _headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec création utilisateur: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur création utilisateur: $e');
    }
  }

  // ==================== PROJETS ====================
  
  static Future<List<Project>> getProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projets/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception('Échec récupération projets: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur récupération projets: $e');
    }
  }

  static Future<Project> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projets/'),
        headers: _headers,
        body: json.encode(projectData),
      );

      if (response.statusCode == 201) {
        return Project.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec création projet: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur création projet: $e');
    }
  }

  static Future<Project> updateProject(int id, Map<String, dynamic> projectData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/projets/$id/'),
        headers: _headers,
        body: json.encode(projectData),
      );

      if (response.statusCode == 200) {
        return Project.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec mise à jour projet: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur mise à jour projet: $e');
    }
  }

  static Future<void> deleteProject(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/projets/$id/'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Échec suppression projet: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur suppression projet: $e');
    }
  }

  // ==================== TÂCHES ====================
  
  static Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/taches/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Échec récupération tâches: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur récupération tâches: $e');
    }
  }

  static Future<Task> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/taches/'),
        headers: _headers,
        body: json.encode(taskData),
      );

      if (response.statusCode == 201) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec création tâche: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur création tâche: $e');
    }
  }

  static Future<Task> updateTask(int id, Map<String, dynamic> taskData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/taches/$id/'),
        headers: _headers,
        body: json.encode(taskData),
      );

      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec mise à jour tâche: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur mise à jour tâche: $e');
    }
  }

  static Future<void> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/taches/$id/'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Échec suppression tâche: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur suppression tâche: $e');
    }
  }
} 