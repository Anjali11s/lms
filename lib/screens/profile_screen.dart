import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lms/screens/opportunities_screen.dart';
import 'package:lms/screens/notes_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSendingVerification = false;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Real data variables
  int _notesCount = 0;
  int _opportunitiesCount = 0;
  bool _isLoading = true;
  
  // User data that can be edited
  String _userName = "Anjali";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userName = user?.displayName ?? "Anjali";
    });
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      debugPrint('=== FETCHING PROFILE DATA FOR USER ===');
      debugPrint('User UID: ${currentUser.uid}');
      debugPrint('User Email: ${currentUser.email}');

      // Fetch only notes and opportunities counts for current user
      await _fetchNotesCount(currentUser.uid);
      await _fetchOpportunitiesCount();

      debugPrint('=== PROFILE DATA RESULTS ===');
      debugPrint('My Notes: $_notesCount');
      debugPrint('My Opportunities: $_opportunitiesCount');

    } catch (e) {
      debugPrint('Error fetching profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile data: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchNotesCount(String uid) async {
    try {
      // Fetch only notes created by the current user
      final response = await _supabase
          .from('notes')
          .select()
          .eq('author_id', uid) // Filter by user ID
          .limit(1000);
      
      _notesCount = response.length;
      
      debugPrint('User notes count: $_notesCount for user: $uid');
      
      // Fallback: if no notes found with author_id, try filtering by email
      if (_notesCount == 0) {
        final user = FirebaseAuth.instance.currentUser;
        if (user?.email != null) {
          final emailResponse = await _supabase
              .from('notes')
              .select()
              .eq('author_email', user!.email!)
              .limit(1000);
          
          _notesCount = emailResponse.length;
          debugPrint('User notes count (by email): $_notesCount for email: ${user.email}');
        }
      }
      
    } catch (e) {
      debugPrint('Error fetching user notes count: $e');
      _notesCount = 0;
    }
  }

  Future<void> _fetchOpportunitiesCount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _opportunitiesCount = 0;
        return;
      }
      
      // Fetch only opportunities created by the current user
      final response = await _supabase
          .from('opportunities')
          .select('id')
          .eq('created_by', currentUser.uid); // Filter by user ID
      
      _opportunitiesCount = response.length;
      debugPrint('User opportunities count: $_opportunitiesCount for user: ${currentUser.uid}');
      
      // Fallback: if no opportunities found with created_by, try filtering by email
      if (_opportunitiesCount == 0 && currentUser.email != null) {
        final emailResponse = await _supabase
            .from('opportunities')
            .select('id')
            .eq('created_by_email', currentUser.email!);
        
        _opportunitiesCount = emailResponse.length;
        debugPrint('User opportunities count (by email): $_opportunitiesCount for email: ${currentUser.email}');
      }
    } catch (e) {
      debugPrint('Error fetching user opportunities count: $e');
      _opportunitiesCount = 0;
    }
  }

  // Edit Name Functionality
  void _editName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = 
            TextEditingController(text: _userName);
        
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await _updateUserName(nameController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserName(String newName) async {
    if (newName == _userName) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        
        setState(() {
          _userName = newName;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating name: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating name: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (!mounted) return;
    
    setState(() => _isSendingVerification = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, 
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
      onTap: onTap,
    );
  }

  void _navigateToNotesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotesScreen(),
      ),
    );
  }

  void _navigateToOpportunitiesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OpportunitiesScreen(),
      ),
    );
  }

  void _navigateToMyNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotesScreen(),
      ),
    );
  }

  void _navigateToMyApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OpportunitiesScreen(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final emailVerified = user?.emailVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProfileData,
            tooltip: 'Refresh data',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editName,
            tooltip: 'Edit Name',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: emailVerified ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'No email',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    if (!emailVerified)
                      OutlinedButton(
                        onPressed: _isSendingVerification ? null : _sendVerificationEmail,
                        child: _isSendingVerification
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Verify Email'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats Cards - Show user-specific counts
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'My Notes', 
                    _notesCount.toString(), 
                    Icons.note,
                    onTap: _navigateToNotesScreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'My Opportunities', 
                    _opportunitiesCount.toString(), 
                    Icons.work,
                    onTap: _navigateToOpportunitiesScreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Menu Items
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildMenuItem('My Notes', Icons.note, _navigateToMyNotes),
                  const Divider(height: 1),
                  _buildMenuItem('Opportunities', Icons.work, _navigateToMyApplications),
                  const Divider(height: 1),
                  _buildMenuItem('Settings', Icons.settings, () => _showComingSoon('Settings')),
                  const Divider(height: 1),
                  _buildMenuItem('Help & Support', Icons.help, () => _showComingSoon('Help & Support')),
                  const Divider(height: 1),
                  _buildMenuItem('About', Icons.info, () => _showComingSoon('About')),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}