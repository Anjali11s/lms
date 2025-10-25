import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lms/screens/upload_note.dart';
import 'auth_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/opportunities_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_opportunity_screen.dart'; 


import 'package:supabase_flutter/supabase_flutter.dart' hide User;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Supabase.initialize(
      url: 'https://emvwvjxtfoshvbdnzkfx.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtdnd2anh0Zm9zaHZiZG56a2Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2ODI0ODIsImV4cCI6MjA2ODI1ODQ4Mn0._-_56yBz3I6xjUAX7hsW2VfpafneqjeD3wNTk7oBdWQ',
    );

    runApp(const CollegeNotesApp());
  } catch (e) {
    print("Firebase Init Error: $e");
  }
}

class CollegeNotesApp extends StatelessWidget {
  const CollegeNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Notes & Opportunities',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return const MainScreen(); // already logged in
          } else {
            return const AuthScreen(); // not logged in
          }
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NotesScreen(),
    const OpportunitiesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outlined),
            selectedIcon: Icon(Icons.work),
            label: 'Opportunities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddDialog(context);
              },
              icon: const Icon(Icons.add),
              label: Text(_selectedIndex == 1 ? 'Add Note' : 'Add Opportunity'),
            )
          : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    if (_selectedIndex == 1) {
      // Navigate to UploadNotePage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadNoteScreen()),
      );
    } else if (_selectedIndex == 2) {
      // Navigate to AddOpportunityScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddOpportunityScreen()),
      ).then((_) {
        // Refresh the opportunities screen when returning
        // This will trigger a refresh if the opportunities screen is active
        if (mounted && _selectedIndex == 2) {
          // You might want to implement a refresh mechanism in OpportunitiesScreen
          // For now, we'll just set state to potentially trigger a rebuild
          setState(() {});
        }
      });
    }
  }
}
