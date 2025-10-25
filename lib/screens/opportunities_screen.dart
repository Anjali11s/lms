import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_opportunity_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  final String? selectedOpportunityId;

  const OpportunitiesScreen({super.key, this.selectedOpportunityId});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  String selectedType = 'All';
  List<dynamic> opportunities = [];
  List<dynamic> filteredOpportunities = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedOpportunityId;

  final List<String> types = [
    'All',
    'Internship',
    'Job',
    'Research',
    'Event',
    'Workshop',
  ];

  @override
  void initState() {
    super.initState();
    _selectedOpportunityId = widget.selectedOpportunityId;
    
    // Debug the received ID
    debugPrint('=== OPPORTUNITIES SCREEN INIT ===');
    debugPrint('Received selectedOpportunityId: $_selectedOpportunityId');
    debugPrint('Type: ${_selectedOpportunityId.runtimeType}');
    
    fetchOpportunities();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterOpportunities();
  }

  void _filterOpportunities() {
    final searchTerm = _searchController.text.toLowerCase();
    
    setState(() {
      if (searchTerm.isEmpty) {
        filteredOpportunities = opportunities;
      } else {
        filteredOpportunities = opportunities.where((opp) {
          final title = opp['title']?.toString().toLowerCase() ?? '';
          final company = opp['company']?.toString().toLowerCase() ?? '';
          final description = opp['description']?.toString().toLowerCase() ?? '';
          final type = opp['type']?.toString().toLowerCase() ?? '';
          
          return title.contains(searchTerm) ||
                 company.contains(searchTerm) ||
                 description.contains(searchTerm) ||
                 type.contains(searchTerm);
        }).toList();
      }
      
      if (selectedType != 'All') {
        filteredOpportunities = filteredOpportunities.where((o) => o['type'] == selectedType).toList();
      }
    });

    // Scroll after filtering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedOpportunity();
    });
  }

  Future<void> fetchOpportunities() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('opportunities')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          opportunities = response;
          filteredOpportunities = response;
        });
        
        // Debug the fetched data
        debugPrint('=== FETCHED OPPORTUNITIES ===');
        debugPrint('Total opportunities: ${response.length}');
        if (response.isNotEmpty) {
          debugPrint('First opportunity ID: ${response[0]['id']} (type: ${response[0]['id'].runtimeType})');
          debugPrint('First opportunity title: ${response[0]['title']}');
        }
        
        // Scroll after data is loaded and UI is built
        if (_selectedOpportunityId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSelectedOpportunity();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching opportunities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading opportunities: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _scrollToSelectedOpportunity() {
    if (_selectedOpportunityId == null) return;
    
    debugPrint('=== SCROLLING TO SELECTED OPPORTUNITY ===');
    debugPrint('Looking for ID: $_selectedOpportunityId');
    debugPrint('Filtered opportunities count: ${filteredOpportunities.length}');
    
    // Try both string and int comparison since IDs might be different types
    final index = filteredOpportunities.indexWhere((opp) {
      final oppId = opp['id'];
      return oppId.toString() == _selectedOpportunityId || 
             oppId == int.tryParse(_selectedOpportunityId!);
    });
    
    debugPrint('Found at index: $index');
    
    if (index != -1) {
      if (_scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add a small delay to ensure the list is fully built
          Future.delayed(const Duration(milliseconds: 100), () {
            final position = index * 160.0; // Increased item height estimate
            debugPrint('Scrolling to position: $position');
            
            _scrollController.animateTo(
              position,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          });
        });
      } else {
        debugPrint('Scroll controller has no clients yet');
      }
    } else {
      debugPrint('Opportunity not found in filtered list');
      // Debug all IDs to see what's available
      for (var i = 0; i < filteredOpportunities.length; i++) {
        final opp = filteredOpportunities[i];
        debugPrint('Index $i: ID=${opp['id']} (type: ${opp['id'].runtimeType}), Title=${opp['title']}');
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedOpportunityId = null;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedOpportunityId != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: 'Clear selection',
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddOpportunityScreen(),
                ),
              ).then((_) {
                fetchOpportunities();
              });
            },
          ),
          // Temporary debug button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              debugPrint('=== MANUAL DEBUG TRIGGER ===');
              _scrollToSelectedOpportunity();
            },
            tooltip: 'Debug scroll',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search opportunities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Filter Row
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                final isSelected = type == selectedType;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedType = type);
                    _filterOpportunities();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Opportunities List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOpportunities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty && selectedType == 'All'
                                  ? 'No opportunities available yet.'
                                  : 'No opportunities found.',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_searchController.text.isNotEmpty || selectedType != 'All')
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    selectedType = 'All';
                                    filteredOpportunities = opportunities;
                                  });
                                },
                                child: const Text('Clear filters'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchOpportunities,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: filteredOpportunities.length,
                          itemBuilder: (context, index) {
                            final opp = filteredOpportunities[index];
                            
                            // Handle both string and int ID comparison
                            final isSelected = opp['id'].toString() == _selectedOpportunityId || 
                                             opp['id'] == int.tryParse(_selectedOpportunityId ?? '');

                            // Debug selected item
                            if (isSelected) {
                              debugPrint('=== BUILDING SELECTED ITEM ===');
                              debugPrint('Index: $index');
                              debugPrint('Opp ID: ${opp['id']} (type: ${opp['id'].runtimeType})');
                              debugPrint('Selected ID: $_selectedOpportunityId (type: ${_selectedOpportunityId.runtimeType})');
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 3, // Thicker border for visibility
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: isSelected ? 4 : 2,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: _getColorForType(opp['type']?.toString()),
                                    child: Icon(
                                      _getIconForType(opp['type']?.toString()),
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    opp['title']?.toString() ?? 'No Title',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        opp['company']?.toString() ?? 'Unknown Company',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        opp['description']?.toString() ?? 'No description available',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      if (opp['deadline'] != null)
                                        Text(
                                          'Deadline: ${_formatDate(opp['deadline'])}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: opp['link'] != null && 
                                           opp['link'].toString().isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.open_in_new, size: 20),
                                          onPressed: () {
                                            _launchURL(opp['link']);
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String? type) {
    final typeString = type?.toString() ?? '';
    switch (typeString) {
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
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  IconData _getIconForType(String? type) {
    final typeString = type?.toString() ?? '';
    switch (typeString) {
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