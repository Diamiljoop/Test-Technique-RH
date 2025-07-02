import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _selectedRole = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Erreur: ${userProvider.error}'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => userProvider.fetchUsers(),
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                List<User> filteredUsers = _getFilteredUsers(userProvider.users);

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aucun utilisateur trouvé'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showAddUserDialog(context),
                          child: Text('Ajouter un utilisateur'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => userProvider.fetchUsers(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(context, user, userProvider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filtrer par rôle:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedRole,
            items: [
              DropdownMenuItem(value: 'Tous', child: Text('Tous')),
              DropdownMenuItem(value: 'gestionnaire', child: Text('Gestionnaires')),
              DropdownMenuItem(value: 'utilisateur', child: Text('Utilisateurs')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  List<User> _getFilteredUsers(List<User> users) {
    if (_selectedRole == 'Tous') {
      return users;
    }
    return users.where((user) => user.role == _selectedRole).toList();
  }

  Widget _buildUserCard(BuildContext context, User user, UserProvider userProvider) {
    Color roleColor;
    IconData roleIcon;
    
    switch (user.role) {
      case 'gestionnaire':
        roleColor = Colors.purple;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'utilisateur':
        roleColor = Colors.blue;
        roleIcon = Icons.person;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.help;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          child: Icon(roleIcon, color: Colors.white),
        ),
        title: Text(
          user.username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'ACTIF' : 'INACTIF',
                    style: TextStyle(
                      color: user.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user, userProvider),
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
              value: 'role',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Changer rôle'),
                ],
              ),
            ),
            if (user.isActive)
              PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Désactiver'),
                  ],
                ),
              )
            else
              PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activer'),
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
        ),
      ),
    );
  }

  void _handleUserAction(String action, User user, UserProvider userProvider) async {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, user);
        break;
      case 'role':
        _showRoleChangeDialog(context, user, userProvider);
        break;
      case 'activate':
        await _activateUser(user, userProvider);
        break;
      case 'deactivate':
        await _deactivateUser(user, userProvider);
        break;
      case 'delete':
        _showDeleteConfirmation(context, user, userProvider);
        break;
    }
  }

  void _showAddUserDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _usernameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _passwordConfirmController = TextEditingController();
    String _selectedRole = 'utilisateur';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un utilisateur'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom d\'utilisateur est requis';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'email est requis';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe est requis';
                    }
                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(labelText: 'Confirmer le mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(labelText: 'Rôle'),
                  items: [
                    DropdownMenuItem(value: 'utilisateur', child: Text('Utilisateur')),
                    DropdownMenuItem(value: 'gestionnaire', child: Text('Gestionnaire')),
                  ],
                  onChanged: (value) {
                    _selectedRole = value!;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                await Provider.of<UserProvider>(context, listen: false).createUser(
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  passwordConfirm: _passwordConfirmController.text,
                  role: _selectedRole,
                );
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final _formKey = GlobalKey<FormState>();
    final _usernameController = TextEditingController(text: user.username);
    final _emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier l\'utilisateur'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom d\'utilisateur est requis';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'email est requis';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                await Provider.of<UserProvider>(context, listen: false).updateUser(
                  user.id,
                  username: _usernameController.text,
                  email: _emailController.text,
                );
              }
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeDialog(BuildContext context, User user, UserProvider userProvider) {
    String newRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le rôle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Changer le rôle de ${user.username}'),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: newRole,
              decoration: InputDecoration(labelText: 'Nouveau rôle'),
              items: [
                DropdownMenuItem(value: 'utilisateur', child: Text('Utilisateur')),
                DropdownMenuItem(value: 'gestionnaire', child: Text('Gestionnaire')),
              ],
              onChanged: (value) {
                newRole = value!;
              },
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
              Navigator.of(context).pop();
              await userProvider.updateUserRole(user.id, newRole);
            },
            child: Text('Changer'),
          ),
        ],
      ),
    );
  }

  Future<void> _activateUser(User user, UserProvider userProvider) async {
    try {
      await userProvider.activateUser(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur activé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'activation: $e')),
      );
    }
  }

  Future<void> _deactivateUser(User user, UserProvider userProvider) async {
    try {
      await userProvider.deactivateUser(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur désactivé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la désactivation: $e')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, User user, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur ${user.username} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await userProvider.deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
} 