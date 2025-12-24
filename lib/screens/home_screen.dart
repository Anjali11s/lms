import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lms/screens/opportunities_screen.dart';
import 'package:lms/screens/notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  
  // State variables
  int notesCount = 0;
  int opportunitiesCount = 0;
  List<dynamic> recentNotes = [];
  List<dynamic> recentOpportunities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    setState(() => isLoading = true);

    try {
      // Fetch recent notes and opportunities
      final notesResponse = await supabase
          .from('notes')
          .select()
          .order('created_at', ascending: false)
          .limit(3);

      final opportunitiesResponse = await supabase
          .from('opportunities')
          .select()
          .order('created_at', ascending: false)
          .limit(2);

      // For counts, fetch all data and count manually - this always works
      final allNotes = await supabase
          .from('notes')
          .select()
          .limit(1000); // Set a reasonable limit

      final allOpportunities = await supabase
          .from('opportunities')
          .select()
          .limit(1000); // Set a reasonable limit

      if (mounted) {
        setState(() {
          recentNotes = notesResponse;
          recentOpportunities = opportunitiesResponse;
          notesCount = allNotes.length;
          opportunitiesCount = allOpportunities.length;
          
          // Debug print to verify counts
          debugPrint('=== HOME DATA DEBUG ===');
          debugPrint('Notes count: ${allNotes.length}');
          debugPrint('Opportunities count: ${allOpportunities.length}');
          debugPrint('Recent notes: ${notesResponse.length}');
          debugPrint('Recent opportunities: ${opportunitiesResponse.length}');
          debugPrint('First note title: ${notesResponse.isNotEmpty ? notesResponse[0]['title'] : 'No notes'}');
          debugPrint('First opportunity title: ${opportunitiesResponse.isNotEmpty ? opportunitiesResponse[0]['title'] : 'No opportunities'}');
        });
      }
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Simple count method that always works
  Future<void> _fetchHomeDataSimple() async {
    setState(() => isLoading = true);

    try {
      // Fetch everything we need in parallel
      final [allNotes, allOpportunities] = await Future.wait([
        supabase.from('notes').select().order('created_at', ascending: false),
        supabase.from('opportunities').select().order('created_at', ascending: false),
      ]);

      if (mounted) {
        setState(() {
          // Get recent items (first 3 notes, first 2 opportunities)
          recentNotes = allNotes.take(3).toList();
          recentOpportunities = allOpportunities.take(2).toList();
          
          // Get total counts
          notesCount = allNotes.length;
          opportunitiesCount = allOpportunities.length;
          
          debugPrint('=== SIMPLE METHOD DEBUG ===');
          debugPrint('Total notes: $notesCount');
          debugPrint('Total opportunities: $opportunitiesCount');
        });
      }
    } catch (e) {
      debugPrint('Error in simple method: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getTimeLeft(String? deadline) {
    if (deadline == null) return 'No deadline';
    
    try {
      final deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now);
      
      if (difference.inDays == 0) {
        return 'Last day';
      } else if (difference.inDays == 1) {
        return '1 day left';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days left';
      } else {
        return 'Expired';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colleges Hub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHomeDataSimple, // Use the simple reliable method
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share knowledge, discover opportunities',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$notesCount notes • $opportunitiesCount opportunities',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Notes Shared',
                          notesCount.toString(),
                          Icons.note,
                          Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotesScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Opportunities',
                          opportunitiesCount.toString(),
                          Icons.work,
                          Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OpportunitiesScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Notes Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Notes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotesScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  recentNotes.isEmpty
                      ? _buildEmptyState('No notes available yet', Icons.note_add)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentNotes.length,
                          itemBuilder: (context, index) {
                            return _buildNoteCard(context, index);
                          },
                        ),
                  const SizedBox(height: 24),

                  // Recent Opportunities Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest Opportunities',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OpportunitiesScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  recentOpportunities.isEmpty
                      ? _buildEmptyState('No opportunities available yet', Icons.work_outline)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentOpportunities.length,
                          itemBuilder: (context, index) {
                            return _buildOpportunityCard(context, index);
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
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

Widget _buildNoteCard(BuildContext context, int index) {
  final note = recentNotes[index];

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  NotesScreen(selectedNoteId: note['id']),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.note, color: Colors.white),
        ),
        title: Text(
          note['title'] ?? 'Untitled Note',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note['subject'] != null) 
              Text(
                note['subject']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            if (note['author_name'] != null) 
              Text(
                'By ${note['author_name']!}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 4),
            Text(
              _formatDate(note['created_at']),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        // REMOVED: Bookmark icon and rating stars from trailing
        // trailing: const Icon(Icons.arrow_forward_ios, size: 16), // Simple forward arrow
      ),
    ),
  );
}


 Widget _buildOpportunityCard(BuildContext context, int index) {
  final opportunity = recentOpportunities[index];

  // Safe conversion of all fields
  final id = opportunity['id']?.toString();
  final title = opportunity['title']?.toString() ?? 'Untitled Opportunity';
  final company = opportunity['company']?.toString();
  final type = opportunity['type']?.toString();
  final description = opportunity['description']?.toString();
  final deadline = opportunity['deadline']?.toString();

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OpportunitiesScreen(selectedOpportunityId: id),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForType(type),
          child: Icon(_getIconForType(type), color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (company != null && company.isNotEmpty)
              Text(company, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (type != null) Text(type),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _getTimeLeft(deadline),
              style: TextStyle(
                fontSize: 12,
                color: _getTimeLeft(deadline) == 'Expired' 
                    ? Colors.red 
                    : _getTimeLeft(deadline) == 'Last day'
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            // FIX: Use the same navigation with selected ID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OpportunitiesScreen(selectedOpportunityId: id),
              ),
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildEmptyState(String message, IconData icon) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'Internship':
        return Colors.blue;
      case 'Job':
        return Colors.green;
      case 'Research':
        return Colors.purple;
      case 'Event':
        return Colors.orange;
      case 'Workshop':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'Internship':
        return Icons.work_outline;
      case 'Job':
        return Icons.business_center;
      case 'Research':
        return Icons.science;
      case 'Event':
        return Icons.event;
      case 'Workshop':
        return Icons.school;
      default:
        return Icons.work;
    }
  }
}