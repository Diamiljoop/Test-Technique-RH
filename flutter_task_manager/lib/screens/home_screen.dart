import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import 'tasks_screen.dart';
import 'projects_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TasksScreen(),
    ProjectsScreen(),
    UsersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final User? authUser = authProvider.currentUser;
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.fetchTasks();
      if (authUser != null && authUser.role != 'utilisateur') {
        final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await projectProvider.fetchProjects();
        await userProvider.fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? authUser = authProvider.currentUser;
    final bool isSimpleUser = authUser != null && authUser.role == 'utilisateur';

    final List<Widget> screens = isSimpleUser
        ? [TasksScreen()]
        : [TasksScreen(), ProjectsScreen(), UsersScreen()];
    final List<BottomNavigationBarItem> navItems = isSimpleUser
        ? [
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tâches',
            ),
          ]
        : [
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tâches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Projets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Utilisateurs',
            ),
          ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex >= navItems.length ? 0 : _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: navItems,
      ),
    );
  }
} 