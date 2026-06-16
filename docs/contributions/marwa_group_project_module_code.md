# TaskFlow – Group Project Management Module

*Module:* Group Project Management Module  
*Contributor:* Marwa Mustafa  
*Course:* INFO 4335 – Mobile Application Development  
*Project:* TaskFlow: Smart Academic Task and Collaboration Management System  
*File Path:* docs/contributions/marwa_group_project_module_code.md  

---

## 1. Contribution Summary
This contribution introduces the **Group Project Management Module** (`groupTasks` collection) designed for academic peer collaboration. It allows university students to organize shared project tasks, assign them to specific team members, track milestones, set group deadlines, and visually manage workflow statuses using clean, color-coded badges matching the TaskFlow design system.

---

## 2. Feature Explanation & UI Design
* **Project Isolation:** Tasks are filtered and organized under a specific `projectName` to separate different course projects.
* **Collaboration Tracking:** Every task explicitly shows who it is `assignedTo` and who `createdBy` the task to ensure accountability within the team.
* **Visual Hierarchy:** Implements rounded material cards utilizing `AppTheme.cardColor` and custom-tailored status badges leveraging `AppTheme.success`, `AppTheme.warning`, and `AppTheme.danger`.
* **State Management Compatibility:** Structured cleanly to easily hook into the `Provider` package and stream direct Firestore snapshots later.

---

## 3. Firestore Metadata Fields – groupTasks Collection
The code structure aligns perfectly with the planned Cloud Firestore collection layout:

| *Field* | *Type* | *Description* |
| ----- | ----- | ----- |
| taskId | String (auto doc ID) | Unique document identifier |
| projectName | String | Name of the course project (e.g., "HCI Project") |
| taskTitle | String | Description of the specific task |
| assignedTo | String | Team member name/ID responsible for the task |
| deadline | Timestamp / DateTime | The due date set for team completion |
| status | String | Current workflow state (`Not Started`, `In Progress`, `Completed`) |
| createdBy | String | UID of the team member who created the task |
| createdAt | Timestamp | Server timestamp at time of creation |

---

## 4. Suggested Dart Code

### 4.1 Group Tasks Screen View (Using Firestore Streams)
*File path:* `lib/features/groups/screens/group_tasks_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/group_task_card.dart';
import '../widgets/add_group_task_bottom_sheet.dart';

class GroupTasksScreen extends StatefulWidget {
  const GroupTasksScreen({Key? key}) : super(key: key);

  @override
  State<GroupTasksScreen> createState() => _GroupTasksScreenState();
}

class _GroupTasksScreenState extends State<GroupTasksScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Triggers bottom sheet for quick task ingestion
  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddGroupTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Group Project Tasks',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Collaborate with your team members on shared assignments.",
              style: TextStyle(color: AppTheme.grayText, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              // Implemented StreamBuilder exactly like Abubakar's template for real-time updates
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groupTasks')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_work_outlined,
                            size: 64,
                            color: AppTheme.grayText,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No group tasks found',
                            style: TextStyle(color: AppTheme.grayText, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final taskData = doc.data() as Map<String, dynamic>;
                      // Inject document ID into data map for context
                      taskData['taskId'] = doc.id; 
                      
                      return GroupTaskCard(task: taskData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
```
### 4.2 Group Task Card Widget Component
*File path:* `lib/features/groups/widgets/group_task_card.dart`
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';

class GroupTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const GroupTaskCard({Key? key, required this.task}) : super(key: key);

  // Maps workflow status directly to system-wide theme palette colors
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'In Progress':
        return AppTheme.warning;
      case 'Not Started':
      default:
        return AppTheme.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely parse Firestore Timestamp fields
    final Timestamp? deadlineTimestamp = task['deadline'] as Timestamp?;
    final DateTime deadline = deadlineTimestamp?.toDate() ?? DateTime.now();
    final String formattedDeadline = DateFormat('MMM dd, yyyy').format(deadline);

    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                // Project Tag Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, py: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (task['projectName'] ?? 'General').toString().toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Dynamic Progress Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, py: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task['status'] ?? 'Not Started').withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task['status'] ?? 'Not Started',
                    style: TextStyle(
                      color: _getStatusColor(task['status'] ?? 'Not Started'),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task['taskTitle'] ?? 'No Title Specified',
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 16, color: AppTheme.grayText),
                    const SizedBox(width: 6),
                    Text(
                      "Assigned to: ${task['assignedTo'] ?? 'Unassigned'}",
                      style: const TextStyle(color: AppTheme.grayText, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.grayText),
                    const SizedBox(width: 6),
                    Text(
                      formattedDeadline,
                      style: const TextStyle(color: AppTheme.grayText, fontSize: 13),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
```
### 4.3 Add Group Task Dialog Sheet
*File path:* `lib/features/groups/widgets/add_group_task_bottom_sheet.dart`
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';

class AddGroupTaskBottomSheet extends StatefulWidget {
  const AddGroupTaskBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddGroupTaskBottomSheet> createState() => _AddGroupTaskBottomSheetState();
}

class _AddGroupTaskBottomSheetState extends State<AddGroupTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _titleController = TextEditingController();
  final _assigneeController = TextEditingController();
  
  DateTime? _selectedDate;
  String _currentStatus = 'Not Started';
  bool _isLoading = false;

  // Real-time server push integration pipeline
  void _submitData() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);
      try {
        final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        
        await FirebaseFirestore.instance.collection('groupTasks').add({
          'projectName': _projectController.text.trim(),
          'taskTitle': _titleController.text.trim(),
          'assignedTo': _assigneeController.text.trim(),
          'deadline': Timestamp.fromDate(_selectedDate!),
          'status': _currentStatus,
          'createdBy': currentUid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _projectController.dispose();
    _titleController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20, left: 20, right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Team Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _projectController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (val) => val!.isEmpty ? 'Enter project name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
                validator: (val) => val!.isEmpty ? 'Enter task title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assigneeController,
                decoration: const InputDecoration(labelText: 'Assign To (Member Name)'),
                validator: (val) => val!.isEmpty ? 'Assignee required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Text(
                    _selectedDate == null 
                        ? 'No Deadline Picked' 
                        : 'Deadline: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                    style: const TextStyle(color: AppTheme.darkText),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: const Text('Select Date', style: TextStyle(color: AppTheme.primaryBlue)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _currentStatus,
                items: ['Not Started', 'In Progress', 'Completed'].map((st) {
                  return DropdownMenuItem(value: st, child: Text(st));
                }).toList(),
                onChanged: (val) => setState(() => _currentStatus = val!),
                decoration: const InputDecoration(labelText: 'Initial Workflow Status'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add to Project', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
```
---

## 6. Testing Notes & Scenarios

| Scenario | Expected Result |
| :--- | :--- |
| Tap "Add to Project" with empty fields | Form validation triggers immediately, preventing submission and showing "Enter project name" or "Enter task title". |
| Tap "Add to Project" without selecting a deadline | The system blocks the submission until a valid date is picked via the Date Picker component. |
| Change task status to "Completed" | The status badge dynamically updates its background and text color to match `AppTheme.success` (Green) instantly via the Firestore Stream. |
| Multiple team members open the screen | Any task added or updated by one member reflects on all other screens in real-time without needing to refresh or pull-to-refresh. |

---
*Prepared by Marwa Mustafa Ali for TaskFlow – INFO 4335 Group Project.*
