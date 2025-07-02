import 'task.dart';

class Project {
  final int id;
  final String nom;
  final String description;
  final DateTime dateCreation;
  final List<Task> taches;

  Project({
    required this.id,
    required this.nom,
    required this.description,
    required this.dateCreation,
    required this.taches,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      dateCreation: DateTime.parse(json['date_creation']),
      taches: json['taches'] != null
          ? (json['taches'] as List).map((task) => Task.fromJson(task)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      'taches': taches.map((task) => task.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Project(id: $id, nom: $nom, description: $description, dateCreation: $dateCreation, taches: $taches)';
  }
} 