import 'user.dart';

class Task {
  final int id;
  final String titre;
  final String description;
  final String statut;
  final DateTime dateCreation;
  final User? assignee;
  final int? assigneeId;
  final int projetId;

  Task({
    required this.id,
    required this.titre,
    required this.description,
    required this.statut,
    required this.dateCreation,
    this.assignee,
    this.assigneeId,
    required this.projetId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      titre: json['titre'],
      description: json['description'] ?? '',
      statut: json['statut'],
      dateCreation: DateTime.parse(json['date_creation']),
      assignee: json['assignee'] != null ? User.fromJson(json['assignee']) : null,
      assigneeId: json['assignee'] != null ? json['assignee']['id'] : null,
      projetId: json['projet'] ?? json['projet_id'] ?? (throw Exception("projetId manquant dans la tâche: ${json}")),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'assignee': assignee?.toJson(),
      'assignee_id': assigneeId,
      'projet_id': projetId,
    };
  }

  Task copyWith({
    int? id,
    String? titre,
    String? description,
    String? statut,
    DateTime? dateCreation,
    User? assignee,
    int? assigneeId,
    int? projetId,
  }) {
    return Task(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      assignee: assignee ?? this.assignee,
      assigneeId: assigneeId ?? this.assigneeId,
      projetId: projetId ?? this.projetId,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, titre: $titre, description: $description, statut: $statut, dateCreation: $dateCreation, assignee: $assignee, assigneeId: $assigneeId, projetId: $projetId)';
  }
} 