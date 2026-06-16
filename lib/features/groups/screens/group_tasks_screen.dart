import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class GroupTasksScreen extends StatelessWidget {
  const GroupTasksScreen({super.key});

  Future<void> _showAddTaskSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => const _AddGroupTaskSheet(),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'In Progress':
        return AppTheme.warning;
      default:
        return AppTheme.danger;
    }
  }

  DateTime _deadlineFromData(Map<String, dynamic> data) {
    final value = data['deadline'];

    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.now();
  }

  Future<void> _updateStatus(String documentId, String status) async {
    await FirebaseFirestore.instance
        .collection('groupTasks')
        .doc(documentId)
        .update({'status': status});
  }

  Future<void> _deleteTask(String documentId) async {
    await FirebaseFirestore.instance
        .collection('groupTasks')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('groupTasks')
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
                    'Group Tasks',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddTaskSheet(context),
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
                'Assign and track work for shared academic projects.',
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
                            'Could not load group tasks.\n${snapshot.error}',
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
                                Icons.groups_outlined,
                                size: 64,
                                color: AppTheme.grayText.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No group tasks yet',
                                style: TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap Add to create your first group task.',
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
                    final status = data['status']?.toString() ?? 'Not Started';
                    final deadline = _deadlineFromData(data);

                    return Card(
                      color: AppTheme.cardColor,
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.groups_outlined,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['taskTitle']?.toString() ??
                                            'No Task',
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
                                        data['projectName']?.toString() ??
                                            'No Project',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppTheme.grayText,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      await _deleteTask(doc.id);
                                    } else {
                                      await _updateStatus(doc.id, value);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'Not Started',
                                      child: Text('Mark Not Started'),
                                    ),
                                    PopupMenuItem(
                                      value: 'In Progress',
                                      child: Text('Mark In Progress'),
                                    ),
                                    PopupMenuItem(
                                      value: 'Completed',
                                      child: Text('Mark Completed'),
                                    ),
                                    PopupMenuDivider(),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Assigned to: ${data['assignedTo']?.toString() ?? 'Unassigned'}',
                              style: const TextStyle(
                                color: AppTheme.grayText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _GroupBadge(
                                  text: status,
                                  color: _statusColor(status),
                                  icon: Icons.track_changes_outlined,
                                ),
                                _GroupBadge(
                                  text: DateFormat.yMMMd().format(deadline),
                                  color: AppTheme.primaryBlue,
                                  icon: Icons.calendar_month_outlined,
                                ),
                              ],
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

class _AddGroupTaskSheet extends StatefulWidget {
  const _AddGroupTaskSheet();

  @override
  State<_AddGroupTaskSheet> createState() => _AddGroupTaskSheetState();
}

class _AddGroupTaskSheetState extends State<_AddGroupTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _taskController = TextEditingController();
  final _assignedToController = TextEditingController();

  DateTime? _selectedDeadline;
  String _selectedStatus = 'Not Started';
  bool _isSaving = false;

  @override
  void dispose() {
    _projectController.dispose();
    _taskController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDeadline = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a deadline.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login before adding group tasks.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await FirebaseFirestore.instance.collection('groupTasks').add({
        'projectName': _projectController.text.trim(),
        'taskTitle': _taskController.text.trim(),
        'assignedTo': _assignedToController.text.trim(),
        'deadline': Timestamp.fromDate(_selectedDeadline!),
        'status': _selectedStatus,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Group task added successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not save group task: $error'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadlineText = _selectedDeadline == null
        ? 'Select Deadline'
        : DateFormat.yMMMd().format(_selectedDeadline!);

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
                'Add Group Task',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Assign responsibility and track group work.',
                style: TextStyle(color: AppTheme.grayText, fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _projectController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: Icon(Icons.task_alt_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assignedToController,
                decoration: const InputDecoration(
                  labelText: 'Assigned To',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Assigned member is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppTheme.primaryBlue,
                ),
                title: Text(
                  deadlineText,
                  style: const TextStyle(color: AppTheme.darkText),
                ),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.track_changes_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Not Started',
                    child: Text('Not Started'),
                  ),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTask,
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
                  label: Text(_isSaving ? 'Saving...' : 'Save Group Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupBadge extends StatelessWidget {
  const _GroupBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
