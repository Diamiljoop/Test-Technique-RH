import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';

class ProjectsScreen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          if (projectProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (projectProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erreur: ${projectProvider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => projectProvider.fetchProjects(),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (projectProvider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun projet trouvé'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddProjectDialog(context),
                    child: Text('Ajouter un projet'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => projectProvider.fetchProjects(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: projectProvider.projects.length,
              itemBuilder: (context, index) {
                final project = projectProvider.projects[index];
                return _buildProjectCard(context, project, projectProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project, ProjectProvider projectProvider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade700,
          child: Icon(Icons.folder, color: Colors.white),
        ),
        title: Text(
          project.nom,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.description),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Créé le ${_formatDate(project.dateCreation)}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${project.taches.length} tâches',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditProjectDialog(context, project);
            } else if (value == 'delete') {
              _showDeleteProjectDialog(context, project, projectProvider);
            }
          },
        ),
        onTap: () => _showEditProjectDialog(context, project),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un projet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nom du projet',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final success = await Provider.of<ProjectProvider>(context, listen: false)
                    .createProject(
                  nameController.text,
                  descriptionController.text,
                );

                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Projet créé avec succès')),
                  );
                }
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    final nameController = TextEditingController(text: project.nom);
    final descriptionController = TextEditingController(text: project.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le projet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nom du projet',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Provider.of<ProjectProvider>(context, listen: false)
                  .updateProject(
                project.id,
                nameController.text,
                descriptionController.text,
              );

              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Projet modifié avec succès')),
                );
              }
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProjectDialog(BuildContext context, Project project, ProjectProvider projectProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le projet'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${project.nom}" ?\n\nCette action supprimera également toutes les tâches associées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await projectProvider.deleteProject(project.id);
              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Projet supprimé avec succès')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
} 