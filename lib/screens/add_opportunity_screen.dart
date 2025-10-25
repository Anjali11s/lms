import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddOpportunityScreen extends StatefulWidget {
  const AddOpportunityScreen({super.key});

  @override
  State<AddOpportunityScreen> createState() => _AddOpportunityScreenState();
}

class _AddOpportunityScreenState extends State<AddOpportunityScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _deadlineController = TextEditingController();

  String _selectedType = 'Internship';
  bool _isLoading = false;

  final List<String> _types = [
    'Internship',
    'Job',
    'Research',
    'Event',
    'Workshop',
  ];

  @override
  void initState() {
    super.initState();
    // Set default deadline to 30 days from now
    _deadlineController.text = _formatDate(DateTime.now().add(const Duration(days: 30)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submitOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      
      await supabase.from('opportunities').insert({
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'link': _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        'deadline': _deadlineController.text.trim(),
        'posted_by': user?.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding opportunity: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Opportunity'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Software Engineer Intern',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Company Field
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company/Organization *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Google, University Lab',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a company or organization';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the opportunity...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Link Field
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Application Link (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/apply',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Deadline Field
              TextFormField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  labelText: 'Deadline *',
                  border: const OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _isLoading ? null : () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: _isLoading ? null : () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select a deadline';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOpportunity,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Opportunity',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}