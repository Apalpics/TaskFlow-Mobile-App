import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  Future<void> _openAddFileSheet(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login before adding files.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => _AddFileSheet(userId: user.uid),
    );
  }

  Future<void> _deleteFile(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('files')
          .doc(documentId)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File record deleted.')));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete file record: $error'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  IconData _fileIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _dateText(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('d MMM yyyy, h:mm a').format(value.toDate());
    }

    return 'Saving date...';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view files.',
          style: TextStyle(color: AppTheme.grayText),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('files')
        .where('uploadedBy', isEqualTo: user.uid)
        .snapshots();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'My Files',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddFileSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Save file names and notes for your assignments.',
                style: TextStyle(color: AppTheme.grayText, fontSize: 13),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: AppTheme.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Could not load files.\n${snapshot.error}',
                            style: TextStyle(color: AppTheme.danger),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      Card(
                        color: AppTheme.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_open_outlined,
                                size: 64,
                                color: AppTheme.grayText.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No files saved yet',
                                style: TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap Add to save file information.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.grayText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final type = data['fileType']?.toString() ?? 'unknown';

                    return Card(
                      color: AppTheme.cardColor,
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _fileIcon(type),
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['fileName']?.toString() ??
                                        'Unnamed File',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.darkText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['assignmentTitle']?.toString() ??
                                        'No Assignment',
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if ((data['note']?.toString() ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      data['note'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppTheme.grayText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    _dateText(data['uploadedAt']),
                                    style: const TextStyle(
                                      color: AppTheme.grayText,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteFile(context, doc.id),
                              icon: const Icon(Icons.delete_outline),
                              color: AppTheme.danger,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFileSheet extends StatefulWidget {
  const _AddFileSheet({required this.userId});

  final String userId;

  @override
  State<_AddFileSheet> createState() => _AddFileSheetState();
}

class _AddFileSheetState extends State<_AddFileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController();
  final _assignmentController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _fileNameController.dispose();
    _assignmentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveFileInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final fileName = _fileNameController.text.trim();
    final parts = fileName.split('.');
    final fileType = parts.length > 1 ? parts.last.toLowerCase() : 'unknown';

    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await FirebaseFirestore.instance.collection('files').add({
        'fileName': fileName,
        'fileType': fileType,
        'assignmentTitle': _assignmentController.text.trim(),
        'note': _noteController.text.trim(),
        'uploadedBy': widget.userId,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('File information saved.')),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not save file info: $error'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add File Info',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Save file metadata without Firebase Storage.',
                style: TextStyle(color: AppTheme.grayText, fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                  hintText: 'example: report.pdf',
                  prefixIcon: Icon(Icons.insert_drive_file_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'File name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assignmentController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Assignment title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveFileInfo,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save File Info'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
