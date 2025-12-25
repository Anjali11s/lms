import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lms/screens/opportunities_screen.dart';
import 'package:lms/screens/notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Conflict demo: changing this line in main branch

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

  Widget _buildWelcomeCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Welcome Back!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Share knowledge and discover opportunities',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$notesCount notes • $opportunitiesCount opportunities',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Widget screen) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 24,
              width: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(right: 12),
            ),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => screen),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, int index) {
    final note = recentNotes[index];
    final color = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotesScreen(selectedNoteId: note['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.note, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'] ?? 'Untitled Note',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (note['subject'] != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          note['subject']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (note['author_name'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'By ${note['author_name']!}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(note['created_at']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, int index) {
    final opportunity = recentOpportunities[index];
    final type = opportunity['type']?.toString();
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    // Safe conversion of all fields
    final id = opportunity['id']?.toString();
    final title = opportunity['title']?.toString() ?? 'Untitled Opportunity';
    final company = opportunity['company']?.toString();
    final description = opportunity['description']?.toString();
    final deadline = opportunity['deadline']?.toString();

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OpportunitiesScreen(selectedOpportunityId: id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (company != null && company.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        company,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (type != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeLeft(deadline),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTimeLeft(deadline) == 'Expired' 
                                ? Colors.red 
                                : _getTimeLeft(deadline) == 'Last day'
                                    ? Colors.orange
                                    : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('College Hub'),
        backgroundColor: colorScheme.inversePrimary,
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
            onPressed: _fetchHomeDataSimple,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHomeDataSimple,
        color: colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card with fade animation
              AnimatedOpacity(
                opacity: isLoading ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: _buildWelcomeCard(),
              ),
              const SizedBox(height: 24),

              // Stats with staggered animation
              AnimatedOpacity(
                opacity: isLoading ? 0 : 1,
                duration: const Duration(milliseconds: 400),
                child: Row(
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
              ),
              const SizedBox(height: 24),

              // Recent Notes Section
              AnimatedOpacity(
                opacity: isLoading ? 0 : 1,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Recent Notes', Icons.note, const NotesScreen()),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Opportunities Section
              AnimatedOpacity(
                opacity: isLoading ? 0 : 1,
                duration: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Latest Opportunities', Icons.work, const OpportunitiesScreen()),
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
            ],
          ),
        ),
      ),
    );
  }
}