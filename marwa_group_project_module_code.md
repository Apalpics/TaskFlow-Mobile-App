# Module Contribution: Group Project Management Module
**Contributor:** Marwa Mustafa  
**File Path:** `docs/contributions/marwa_group_project_module_code.md`  
**Project:** TaskFlow: Smart Academic Task and Collaboration Management System  

---

## 1. Contribution Summary
This contribution introduces the **Group Project Management Module** (`groupTasks` collection) designed for academic peer collaboration. It allows university students to organize shared project tasks, assign them to specific team members, track milestones, set group deadlines, and visually manage workflow statuses using clean, color-coded badges matching the TaskFlow design system.

## 2. Feature Explanation & UI Design
* **Project Isolation:** Tasks are filtered and organized under a specific `projectName` to separate different course projects.
* **Collaboration Tracking:** Every task explicitly shows who it is `assignedTo` and who `createdBy` the task.
* **Visual Hierarchy:** Implements rounded material cards utilizing `AppTheme.cardColor` and custom-tailored status badges leveraging `AppTheme.success`, `AppTheme.warning`, and `AppTheme.danger`.
* **State Management Compatibility:** Structured cleanly to easily hook into the `Provider` package and stream direct Firestore snapshots later.

## 3. Firestore Schema Mapping (`groupTasks`)
The code structure aligns perfectly with the planned Cloud Firestore collection layout:
* `taskId`: String (Document ID)
* `projectName`: String
* `taskTitle`: String
* `assignedTo`: String
* `deadline`: Timestamp / DateTime
* `status`: String
* `createdBy`: String
* `createdAt`: Timestamp

---

## 4. Suggested Dart Implementation

### A. Group Tasks Screen (`lib/features/groups/screens/group_tasks_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class GroupTasksScreen extends StatefulWidget {
  const GroupTasksScreen({Key? key}) : super(key: key);

  @override
  State<GroupTasksScreen> createState() => _GroupTasksScreenState();
}

class _GroupTasksScreenState extends State<GroupTasksScreen> {
  // Local list for UI testing before linking database stream
  final List<Map<String, dynamic>> _mockGroupTasks = [
    {
      'taskId': 'g1',
      'projectName': 'HCI Project',
      'taskTitle': 'Create Figma Wireframes',
      'assignedTo': 'Newal',
      'deadline': DateTime.now().add(const Duration(days: 2)),
      'status': 'In Progress',
    },
    {
      'taskId': 'g2',
      'projectName': 'Mobile App Dev',
      'taskTitle': 'Integrate Cloud Firestore',
      'assignedTo': 'Abubakar',
      'deadline': DateTime.now().add(const Duration(days: 4)),
      'status': 'Not Started',
    },
    {
      'taskId': 'g3',
      'projectName': 'Mobile App Dev',
      'taskTitle': 'Design System Architecture',
      'assignedTo': 'Adil',
      'deadline': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Completed',
    }
  ];

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
              child: ListView.builder(
                itemCount: _mockGroupTasks.length,
                itemBuilder: (context, index) {
                  final task = _mockGroupTasks[index];
                  return GroupTaskCard(task: task);
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
