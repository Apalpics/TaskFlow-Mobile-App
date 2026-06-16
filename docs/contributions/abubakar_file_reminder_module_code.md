# TaskFlow – File Uploads and Reminder System

**Module:** File Uploads and Reminder System
**Contributor:** Abubakar Abdusalam Nataala
**Course:** INFO 4335 – Mobile Application Development
**Project:** TaskFlow: Smart Academic Task and Collaboration Management System
**File Path:** `docs/contributions/abubakar_file_reminder_module_code.md`

---

## 1. Contribution Summary

This contribution covers two closely related features for the TaskFlow app:

- **File Management** – allows students to pick a file from their device using `file_picker`, capture its metadata (name, type, associated assignment, note), and save that metadata to Cloud Firestore under the `files` collection. No binary file content is uploaded because Firebase Storage currently requires billing upgrade; only metadata is persisted.
- **Reminder System** – reads assignment deadlines from Firestore and classifies each assignment into one of four reminder states: **Overdue**, **Due Today**, **Due Tomorrow**, or **Upcoming**. A dedicated reminder card widget renders each state with an appropriate colour badge drawn from `AppTheme`.

---

## 2. Feature Explanation

### File Management

Students frequently need to keep track of assignment-related files (PDFs, images, DOCX). Since Firebase Storage is not available, this module simulates the upload experience by:

1. Opening the device file picker via `file_picker`.
2. Capturing the selected file's name and extension.
3. Letting the student tag the file to an assignment title and add an optional note.
4. Writing a lightweight metadata document to the `files` Firestore collection.
5. Displaying all saved file records in a card list on `FilesScreen`.

### Reminder System

The reminder widget reads from the `assignments` Firestore collection, compares each `deadline` timestamp with today's date, and attaches a priority label. This gives students an at-a-glance view of what needs immediate attention without requiring a separate notifications service.

---

## 3. Firestore Metadata Fields – `files` Collection

| Field | Type | Description |
|---|---|---|
| `fileId` | `String` (auto doc ID) | Unique document identifier |
| `fileName` | `String` | Original file name including extension |
| `assignmentTitle` | `String` | Assignment this file belongs to |
| `fileType` | `String` | Extension extracted from file name (e.g. `pdf`) |
| `note` | `String` | Optional student note about the file |
| `uploadedBy` | `String` | UID of the currently signed-in user |
| `uploadedAt` | `Timestamp` | Server timestamp at time of save |

---

## 4. Suggested Dart Code

### 4.1 `FilesScreen`

**File path:** `lib/features/files/screens/files_screen.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _openAddFileDialog() async {
    String? pickedFileName;
    String? pickedFileExtension;
    final assignmentController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    pickedFileName = result.files.single.name;
    final nameParts = pickedFileName.split('.');
    pickedFileExtension = nameParts.length > 1
        ? nameParts.last.toLowerCase()
        : 'unknown';

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save File Metadata',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    )),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_outlined,
                          color: AppTheme.primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pickedFileName!,
                          style: TextStyle(
                              color: AppTheme.darkText,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: assignmentController,
                  decoration: const InputDecoration(
                    labelText: 'Assignment Title',
                    prefixIcon: Icon(Icons.assignment_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Assignment title is required'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await _saveFileMetadata(
                        fileName: pickedFileName!,
                        fileType: pickedFileExtension!,
                        assignmentTitle: assignmentController.text.trim(),
                        note: noteController.text.trim(),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save File Info'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveFileMetadata({
    required String fileName,
    required String fileType,
    required String assignmentTitle,
    required String note,
  }) async {
    final uid = _auth.currentUser?.uid ?? '';
    await _firestore.collection('files').add({
      'fileName': fileName,
      'fileType': fileType,
      'assignmentTitle': assignmentTitle,
      'note': note,
      'uploadedBy': uid,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteFile(String docId) async {
    await _firestore.collection('files').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('My Files',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddFileDialog,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.attach_file, color: Colors.white),
        label: const Text('Add File',
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('files')
            .where('uploadedBy', isEqualTo: uid)
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              return _FileCard(
                fileName: data['fileName'] ?? '',
                fileType: data['fileType'] ?? '',
                assignmentTitle: data['assignmentTitle'] ?? '',
                note: data['note'] ?? '',
                uploadedAt: data['uploadedAt'] as Timestamp?,
                onDelete: () => _deleteFile(docId),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined,
              size: 64, color: AppTheme.grayText),
          const SizedBox(height: 12),
          Text('No files saved yet',
              style: TextStyle(color: AppTheme.grayText, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Tap "Add File" to attach a file to an assignment',
              style: TextStyle(color: AppTheme.grayText, fontSize: 13)),
        ],
      ),
    );
  }
}
```

---

### 4.2 `_FileCard` Widget

```dart
class _FileCard extends StatelessWidget {
  final String fileName;
  final String fileType;
  final String assignmentTitle;
  final String note;
  final Timestamp? uploadedAt;
  final VoidCallback onDelete;

  const _FileCard({
    required this.fileName,
    required this.fileType,
    required this.assignmentTitle,
    required this.note,
    required this.uploadedAt,
    required this.onDelete,
  });

  IconData _iconForType(String type) {
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
      case 'pptx':
      case 'ppt':
        return Icons.slideshow_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = uploadedAt != null
        ? DateFormat('d MMM yyyy, h:mm a').format(uploadedAt!.toDate())
        : 'Unknown date';

    return Card(
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconForType(fileType),
                  color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fileName,
                      style: TextStyle(
                          color: AppTheme.darkText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(assignmentTitle,
                      style: TextStyle(
                          color: AppTheme.primaryBlue, fontSize: 12)),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(note,
                        style: TextStyle(
                            color: AppTheme.grayText, fontSize: 12)),
                  ],
                  const SizedBox(height: 4),
                  Text(dateStr,
                      style: TextStyle(
                          color: AppTheme.grayText, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: AppTheme.danger, size: 20),
              onPressed: onDelete,
              tooltip: 'Remove file record',
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 4.3 Reminder Logic – `ReminderHelper`

**File path:** `lib/features/files/utils/reminder_helper.dart`

This utility classifies any assignment deadline into one of four categories based on the current date.

```dart
enum ReminderStatus { overdue, dueToday, dueTomorrow, upcoming }

class ReminderHelper {
  static ReminderStatus classify(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay =
        DateTime(deadline.year, deadline.month, deadline.day);
    final diff = deadlineDay.difference(today).inDays;

    if (diff < 0) return ReminderStatus.overdue;
    if (diff == 0) return ReminderStatus.dueToday;
    if (diff == 1) return ReminderStatus.dueTomorrow;
    return ReminderStatus.upcoming;
  }

  static String label(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.overdue:
        return 'Overdue';
      case ReminderStatus.dueToday:
        return 'Due Today';
      case ReminderStatus.dueTomorrow:
        return 'Due Tomorrow';
      case ReminderStatus.upcoming:
        return 'Upcoming';
    }
  }
}
```

---

### 4.4 `ReminderCard` Widget

**File path:** `lib/features/files/widgets/reminder_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../utils/reminder_helper.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final String courseName;
  final DateTime deadline;

  const ReminderCard({
    super.key,
    required this.title,
    required this.courseName,
    required this.deadline,
  });

  Color _badgeColor(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.overdue:
        return AppTheme.danger;
      case ReminderStatus.dueToday:
        return AppTheme.warning;
      case ReminderStatus.dueTomorrow:
        return Colors.orange.shade600;
      case ReminderStatus.upcoming:
        return AppTheme.success;
    }
  }

  IconData _badgeIcon(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.overdue:
        return Icons.error_outline;
      case ReminderStatus.dueToday:
        return Icons.alarm;
      case ReminderStatus.dueTomorrow:
        return Icons.schedule;
      case ReminderStatus.upcoming:
        return Icons.event_available_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ReminderHelper.classify(deadline);
    final badgeColor = _badgeColor(status);
    final dateStr = DateFormat('EEE, d MMM yyyy').format(deadline);

    return Card(
      color: AppTheme.cardColor,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_badgeIcon(status),
                  color: badgeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppTheme.darkText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(courseName,
                      style: TextStyle(
                          color: AppTheme.grayText, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(dateStr,
                      style: TextStyle(
                          color: AppTheme.grayText, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ReminderHelper.label(status),
                style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 4.5 `RemindersScreen` – Reads Assignments and Renders Reminder Cards

**File path:** `lib/features/files/screens/reminders_screen.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/reminder_card.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Reminders',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .where('createdBy', isEqualTo: uid)
            .where('status', whereNotIn: ['Completed'])
            .orderBy('deadline')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined,
                      size: 64, color: AppTheme.grayText),
                  const SizedBox(height: 12),
                  Text('No reminders right now',
                      style: TextStyle(
                          color: AppTheme.grayText, fontSize: 16)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final deadline =
                  (data['deadline'] as Timestamp).toDate();
              return ReminderCard(
                title: data['title'] ?? '',
                courseName: data['courseName'] ?? '',
                deadline: deadline,
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 5. Integration Notes

> **These notes are for the final integrator. Do not edit live app files directly based on this document — review and adapt the code below before integrating.**

### 5.1 Add Routes

In `lib/core/routes/app_routes.dart`, register two new route constants:

```dart
static const String files = '/files';
static const String reminders = '/reminders';
```

In the route map (wherever `MaterialApp` or `GoRouter` is configured):

```dart
AppRoutes.files: (context) => const FilesScreen(),
AppRoutes.reminders: (context) => const RemindersScreen(),
```

### 5.2 Add to Bottom Navigation

In `lib/features/dashboard/screens/main_navigation_screen.dart`, add `FilesScreen` and `RemindersScreen` as tabs in the `NavigationBar` destinations list:

```dart
NavigationDestination(
  icon: Icon(Icons.folder_outlined),
  selectedIcon: Icon(Icons.folder),
  label: 'Files',
),
NavigationDestination(
  icon: Icon(Icons.notifications_outlined),
  selectedIcon: Icon(Icons.notifications),
  label: 'Reminders',
),
```

Add the corresponding screens to the `_screens` list:

```dart
const [
  // ... existing screens ...
  FilesScreen(),
  RemindersScreen(),
]
```

### 5.3 Firestore Composite Index

The `RemindersScreen` query uses:
- `where('createdBy', ...)`
- `where('status', whereNotIn: [...])`
- `orderBy('deadline')`

Firestore will prompt for a composite index the first time this query runs. Follow the link printed in the debug console to create it automatically in the Firebase console.

### 5.4 Required `pubspec.yaml` Dependencies

```yaml
dependencies:
  file_picker: ^8.0.0    # or latest stable
  cloud_firestore: ^4.x.x
  firebase_auth: ^4.x.x
  intl: ^0.18.0
```

---

## 6. Testing Notes

| Scenario | Expected Result |
|---|---|
| Tap "Add File" without selecting a file | Bottom sheet never opens (picker cancel is handled gracefully) |
| Select a file and leave Assignment Title blank | Form validation shows "Assignment title is required" |
| Select a file, fill all fields, tap Save | New card appears in the list with correct file name, assignment, and date |
| Delete a file card | Card is removed from the list and Firestore document is deleted |
| Assignment deadline is yesterday | Reminder card shows **Overdue** badge in red |
| Assignment deadline is today | Reminder card shows **Due Today** badge in amber |
| Assignment deadline is tomorrow | Reminder card shows **Due Tomorrow** badge in orange |
| Assignment deadline is 3+ days away | Reminder card shows **Upcoming** badge in green |
| No assignments exist | Reminders screen shows empty state with bell icon |
| No files saved | Files screen shows empty state with folder icon |
| Completed assignments | Should **not** appear in reminders list (filtered by `status != 'Completed'`) |

---

*Prepared by Abubakar Abdusalam Nataala for TaskFlow – INFO 4335 Group Project.*
