import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final _titleController = TextEditingController();
  final _authorNameController = TextEditingController();
  String? _selectedSubject;
  File? _selectedFile;
  bool _isUploading = false;
  String? _error;
  Uint8List? _fileBytes;
  String? _fileName;

  final List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'English',
    'Computer Science',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFile = null;
        _fileBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadNote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'User not logged in');
      return;
    }

    final title = _titleController.text.trim();
    final authorName = _authorNameController.text.trim();
    final subject = _selectedSubject;

    if (title.isEmpty || subject == null || authorName.isEmpty || (_selectedFile == null && _fileBytes == null)) {
      setState(() => _error = 'Please fill in all fields and select a file');
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      // final filePath = 'notes/${const Uuid().v4()}_${_fileName ?? "file.pdf"}';
      final filePath = '${const Uuid().v4()}_${_fileName ?? "file.pdf"}';


      final fileBytes = _selectedFile != null
          ? await _selectedFile!.readAsBytes()
          : _fileBytes!;

      await supabase.storage.from('notes').uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );

      final fileUrl = supabase.storage.from('notes').getPublicUrl(filePath);

      // final insertResponse = await supabase.from('notes').insert({
      //   'title': title,
      //   'subject': subject,
      //   'file_url': fileUrl,
      //   'author_id': user.uid,
      //   'author_name': authorName,
      //   'rating': 0,
      //   'rating_count': 0,
      //   'downloads': 0,
      //   'created_at': DateTime.now().toIso8601String(),
      // });

      // if (insertResponse.error != null) {
      //   throw Exception(insertResponse.error!.message);
      // }
      // 🔍 RLS Policy Access Test
      try {
        final roleCheck = await supabase.from('notes').select().limit(1);
        print('RLS access test result: $roleCheck');
      } catch (e) {
        print('RLS check failed: $e');
      }

      final roleTest = await Supabase.instance.client
    .from('notes')
    .select()
    .limit(1);

print('RLS test result: $roleTest');

print('Uploading with values:');
print('Title: $title');
print('Subject: $_selectedSubject');
print('Download URL: $fileUrl');
print('Author ID: ${user.uid}'); // Firebase UID
print('Author Name: $authorName');

// print('Supabase session: ${Supabase.instance.client.auth.session()}');

      final insertResponse = await supabase.from('notes').insert({
  'title': title,
  'subject': subject,
  'file_url': fileUrl,
  'author_id': user.uid,
  'author_name': authorName,
  'rating': 0,
  'rating_count': 0,
  'downloads': 0,
  'created_at': DateTime.now().toIso8601String(),
}).select();
print('Insert response: $insertResponse');
if (insertResponse.isEmpty) {
  throw Exception('No data returned. Row may have been blocked by RLS.');
}
// if (insertResponse == null || insertResponse.isEmpty) {
//   throw Exception('Insert failed: No data returned');
// }


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note uploaded successfully')),
      );

      _titleController.clear();
      _authorNameController.clear();
      setState(() {
        _selectedSubject = null;
        _selectedFile = null;
      });
    } catch (e) {
      setState(() => _error = 'Upload failed: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorNameController,
              decoration: const InputDecoration(
                labelText: 'Author Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              items: _subjects.map((subj) => DropdownMenuItem(
                value: subj,
                child: Text(subj),
              )).toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_fileBytes == null ? 'Select PDF File' : 'Change File'),
              onPressed: _pickFile,
            ),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Selected: $_fileName'),
              ),
            const SizedBox(height: 24),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Note'),
                    onPressed: _uploadNote,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                  ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
