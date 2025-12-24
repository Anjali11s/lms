import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'pdf_viewer_screen.dart';

class NotesScreen extends StatefulWidget {
  final String? selectedNoteId;

  const NotesScreen({super.key, this.selectedNoteId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<List<Map<String, dynamic>>> _notesFuture;
  final SupabaseClient _supabase = Supabase.instance.client;
  String _searchQuery = '';
  String _selectedSubject = 'All';
  final List<String> _subjects = [
    'All',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Economics'
    'History',
    'Geography',
    
  ];
  
  final ScrollController _scrollController = ScrollController();
  String? _selectedNoteId;

  @override
  void initState() {
    super.initState();
    _selectedNoteId = widget.selectedNoteId;
    _notesFuture = _fetchNotes();
  }

  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _notesFuture = _fetchNotes();
    });
  }

  List<Map<String, dynamic>> _filterNotes(List<Map<String, dynamic>> notes) {
    var filtered = notes;
    
    if (_selectedSubject != 'All') {
      filtered = filtered.where((note) => note['subject'] == _selectedSubject).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) =>
          (note['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (note['subject']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (note['author_name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }
    
    return filtered;
  }

  Future<void> _openPdfViewer(BuildContext context, String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PDF URL')),
      );
      return;
    }

    try {
      // Test if URL is accessible
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerScreen(url: url),
          ),
        );
      } else {
        throw Exception('PDF not found (Status: ${response.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF: ${e.toString()}')),
      );
    }
  }

  Color _getSubjectColor(String? subject) {
    switch (subject?.toLowerCase()) {
      case 'mathematics': return Colors.blue.shade700;
      case 'physics': return Colors.green.shade700;
      case 'chemistry': return Colors.orange.shade700;
      case 'biology': return Colors.purple.shade700;
      case 'computer science': return Colors.red.shade700;
      case 'economics': return Colors.teal.shade700;
      default: return Colors.grey.shade700;
    }
  }

  void _scrollToSelectedNote(List<Map<String, dynamic>> filteredNotes) {
    if (_selectedNoteId == null) return;
    
    final index = filteredNotes.indexWhere((note) => note['id'] == _selectedNoteId);
    if (index != -1 && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          index * 200.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          if (_selectedNoteId != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: 'Clear selection',
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch<String>(
                context: context,
                delegate: NotesSearchDelegate(),
              );
              if (query != null) {
                setState(() => _searchQuery = query);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _subjects.map((subject) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(subject),
                    selected: _selectedSubject == subject,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubject = selected ? subject : 'All';
                      });
                    },
                    selectedColor: _getSubjectColor(subject),
                    labelStyle: TextStyle(
                      color: _selectedSubject == subject 
                          ? Colors.white 
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotes,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _notesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshNotes,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final notes = snapshot.data ?? [];
                  final filteredNotes = _filterNotes(notes);

                  if (_selectedNoteId != null) {
                    _scrollToSelectedNote(filteredNotes);
                  }

                  if (filteredNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.note_add, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No notes found'),
                          if (_selectedSubject != 'All' || _searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSubject = 'All';
                                  _searchQuery = '';
                                });
                              },
                              child: const Text('Clear filters'),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      final createdAt = DateTime.tryParse(note['created_at'] ?? '');
                      final formattedDate = createdAt != null
                          ? DateFormat('dd MMM yyyy • hh:mm a').format(createdAt.toLocal())
                          : '';
                      final isSelected = note['id'] == _selectedNoteId;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getSubjectColor(note['subject']),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        note['subject'] ?? 'General',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    // Removed bookmark icon button
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  note['title'] ?? 'Untitled',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        note['author_name']?.substring(0, 1) ?? 'A',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      note['author_name'] ?? 'Anonymous',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      formattedDate,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    // Only PDF view button remains
                                    IconButton(
                                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                      onPressed: () {
                                        _openPdfViewer(context, note['file_url']);
                                      },
                                    ),
                                    const Spacer(),
                                    // Removed rating stars, download count, etc.
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotesSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}