# Assignment Management Module

**Name:** Newal Yeshak

## Contribution Summary

This module implements assignment management for TaskFlow, allowing students to create, view, update, and track academic assignments with deadlines, priority levels, and completion status. The screens and widgets below follow the existing `AppTheme` styling and use sample static data; the final integrator will connect them to live Firestore data.

## Feature Explanation

The Assignment Management Module covers:

- **Add Assignment Screen** — a form to create a new assignment with title, course name, description, deadline, priority, and status.
- **Assignment List Card** — a reusable widget to display each assignment with a status badge and priority indicator.
- **Firestore structure** for the `assignments` collection.
- **Form validation** for required fields.
- **Suggested Firestore CRUD logic** (add/read/update/delete), provided as a starting point for review.

## Suggested Dart Code — AddAssignmentScreen

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class AddAssignmentScreen extends StatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDeadline;
  String _priority = 'Medium';
  String _status = 'Pending';

  final List<String> _priorityOptions = ['Low', 'Medium', 'High'];
  final List<String> _statusOptions = ['Pending', 'In Progress', 'Completed'];

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _submitAssignment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a deadline')),
        );
        return;
      }

      // Suggested data object for the final integrator to send to Firestore.
      final newAssignment = {
        'title': _titleController.text.trim(),
        'courseName': _courseController.text.trim(),
        'description': _descriptionController.text.trim(),
        'deadline': _selectedDeadline,
        'priority': _priority,
        'status': _status,
        // 'createdBy': currentUserId,
        // 'createdAt': DateTime.now(),
      };

      // TODO: Final integrator - send newAssignment to Firestore here.
      debugPrint(newAssignment.toString());

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        title: const Text('Add Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Course name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDeadline == null
                      ? 'Select Deadline'
                      : 'Deadline: ${DateFormat.yMMMd().format(_selectedDeadline!)}',
                  style: const TextStyle(color: AppTheme.darkText),
                ),
                trailing: const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: _priorityOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitAssignment,
                child: const Text(
                  'Save Assignment',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Suggested Dart Code — Assignment List Card Widget

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class AssignmentCard extends StatelessWidget {
  final String title;
  final String courseName;
  final DateTime deadline;
  final String priority;
  final String status;
  final VoidCallback? onTap;

  const AssignmentCard({
    super.key,
    required this.title,
    required this.courseName,
    required this.deadline,
    required this.priority,
    required this.status,
    this.onTap,
  });

  Color _statusColor() {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'In Progress':
        return AppTheme.warning;
      default:
        return AppTheme.grayText;
    }
  }

  Color _priorityColor() {
    switch (priority) {
      case 'High':
        return AppTheme.danger;
      case 'Medium':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$courseName  •  ${DateFormat.yMMMd().format(deadline)}',
            style: const TextStyle(color: AppTheme.grayText, fontSize: 12),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _statusColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _priorityColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  color: _priorityColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Suggested Firestore Fields — `assignments` Collection

| Field | Type | Notes |
|---|---|---|
| assignmentId | String | Document ID |
| title | String | Required |
| courseName | String | Required |
| description | String | Required |
| deadline | Timestamp | Required |
| priority | String | Low / Medium / High |
| status | String | Pending / In Progress / Completed |
| createdBy | String | UID of creator |
| createdAt | Timestamp | Server timestamp on creation |

## Form Validation Rules

- `title` — required, cannot be empty or whitespace only.
- `courseName` — required, cannot be empty or whitespace only.
- `description` — required, cannot be empty or whitespace only.
- `deadline` — required, must be selected before submission (today or a future date).
- `priority` — must be one of: Low, Medium, High (defaults to Medium).
- `status` — must be one of: Pending, In Progress, Completed (defaults to Pending).

## Suggested Integration Notes

- Add a route constant such as `AppRoutes.addAssignment` pointing to `AddAssignmentScreen` (already listed as an available route constant).
- Register the route in `lib/core/routes/app_routes.dart`.
- `AssignmentCard` is designed to be used inside a `ListView.builder` on an assignments list screen (e.g. `lib/features/assignments/screens/assignment_list_screen.dart`), once created.
- Suggested Firestore add logic (for integrator review):

```dart
// Suggested - to be reviewed by integrator before use
Future<void> addAssignment(Map<String, dynamic> assignmentData) async {
  await FirebaseFirestore.instance.collection('assignments').add(assignmentData);
}
```

- Suggested Firestore read logic (for integrator review):

```dart
// Suggested - to be reviewed by integrator before use
Stream<QuerySnapshot> getAssignments() {
  return FirebaseFirestore.instance
      .collection('assignments')
      .orderBy('deadline')
      .snapshots();
}
```

## Testing Notes

- Verify the form shows validation errors when title, course name, or description are left empty.
- Verify the date picker opens and only allows selecting today or a future date.
- Verify priority and status dropdowns default correctly and update on selection.
- Verify `AssignmentCard` displays correct status and priority badge colors for each combination (Pending/In Progress/Completed, Low/Medium/High).
- Verify deadline displays in a readable format (e.g. "Jun 17, 2026").
- Confirm no real Firestore write occurs without integrator review, since this is suggested code only.
