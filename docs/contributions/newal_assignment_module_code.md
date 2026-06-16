# Module: Assignment Management Module
**Contributor:** Newal  
**Project:** TaskFlow: Smart Academic Task and Collaboration Management System  
**Course:** INFO 4335 Mobile Application Development  

---

## 1. Contribution Summary
This contribution file provides the clean UI components, strict form validation blueprints, and Firestore collection parameters for the **Assignment Management Module** of TaskFlow. It allows university students to effortlessly create, track, and manage their coursework loads.

This contribution includes:
* `AddAssignmentScreen`: A validated form capturing target course, title, description, deadline, priority status, and progress flags.
* `AssignmentCardWidget`: A highly readable list item displaying assignments with responsive context-driven custom priority styling.
* Local state and database interaction templates explicitly matching the project architecture patterns so the final integrator can easily plug it in.

---

## 2. Assignment Feature Explanation
The assignment management feature acts as a centralized dashboard hub for a student's personal milestones. It uses structural containers styled with the core project constants to visually segment highly critical data fields (like High Priority or Pending status) from less time-sensitive requirements. 

By building independent, predictive form layouts, the final repository code can listen safely to changes using the `Provider` pattern without encountering breaking compile runtime exceptions.

---

## 3. Suggested Firestore Fields for Assignments
Data mapped out from this feature aligns perfectly with the target fields scheduled for the `assignments` collection:

* `assignmentId`: String (Auto-generated unique document identifier)
* `title`: String (Descriptive name of the deliverable)
* `courseName`: String (Academic code prefix, e.g., INFO 4335)
* `description`: String (Specific task milestones, reference criteria, or links)
* `deadline`: DateTime/Timestamp (Target completion time boundary)
* `priority`: String (`Low`, `Medium`, or `High`)
* `status`: String (`Pending`, `In Progress`, or `Completed`)
* `createdBy`: String (UID reference linking back to the `users` owner doc)
* `createdAt`: DateTime/Timestamp (System-generated creation tracking date)

---

## 4. Form Validation Rules
To safeguard structural data integrity before Firebase insertions occur, the following strict client-side evaluation thresholds apply:
1. **Course Name:** Required input field. Must strip spaces (`.trim()`) and ensure character footprint is not zero.
2. **Assignment Title:** Required input field. Must ensure string entry is active to prevent unindexed or unidentifiable Firestore reference structures.
3. **Deadline Date:** Evaluated manually on form trigger processing. Rejects submissions instantly if user bypasses calendar selection with a system-level runtime error flag warning.

---

## 5. Suggested Dart Code

### A. Assignment List Card Widget
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class AssignmentCardWidget extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback? onTap;

  const AssignmentCardWidget({
    Key? key,
    required this.assignment,
    this.onTap,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.danger;
      case 'medium':
        return AppTheme.warning;
      case 'low':
      default:
        return AppTheme.success;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.success;
      case 'in progress':
        return AppTheme.primaryBlue;
      case 'pending':
      default:
        return AppTheme.grayText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime deadline = assignment['deadline'] != null 
        ? (assignment['deadline'] as DateTime) 
        : DateTime.now();
    final String formattedDate = DateFormat('MMM dd, yyyy').format(deadline);

    return Card(
      color: AppTheme.cardColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Text(
                    assignment['courseName'] ?? 'Course Code',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(assignment['priority'] ?? 'Low').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      assignment['priority'] ?? 'Low',
                      style: TextStyle(
                        color: _getPriorityColor(assignment['priority'] ?? 'Low'),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                assignment['title'] ?? 'Untitled Assignment',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (assignment['description'] != null && assignment['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  assignment['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.grayText,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.grayText),
                      const SizedBox(width: 4),
                      Text(
                        'Due: $formattedDate',
                        style: TextStyle(
                          color: AppTheme.grayText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(assignment['status'] ?? 'Pending').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      assignment['status'] ?? 'Pending',
                      style: TextStyle(
                        color: _getStatusColor(assignment['status'] ?? 'Pending'),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

### B. Add Assignment Screen Form
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class AddAssignmentScreen extends StatefulWidget {
  const AddAssignmentScreen({Key? key}) : super(key: key);

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime? _selectedDeadline;
  String _selectedPriority = 'Medium';
  String _selectedStatus = 'Pending';
  bool _isLoading = false;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = ['Pending', 'In Progress', 'Completed'];

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
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid target deadline date.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> assignmentPayload = {
        'title': _titleController.text.trim(),
        'courseName': _courseController.text.trim(),
        'description': _descriptionController.text.trim(),
        'deadline': _selectedDeadline, 
        'priority': _selectedPriority,
        'status': _selectedStatus,
        'createdAt': DateTime.now(),
      };

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module Data generated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Add Assignment', 
          style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.darkText),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Course Name', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _courseController,
                      decoration: InputDecoration(
                        hintText: 'e.g., INFO 4335',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Course designation identifier required' : null,
                    ),
                    const SizedBox(height: 16),

                    Text('Assignment Title', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Project Deliverable Phase 1',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Assignment milestone title required' : null,
                    ),
                    const SizedBox(height: 16),

                    Text('Description / Submission Requirements', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Provide grading criteria parameters or platform documentation expectations...',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Deadline Date', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDeadline,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text(
                              _selectedDeadline == null
                                  ? 'Select Due Target Calendar'
                                  : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDeadline!),
                              style: TextStyle(color: _selectedDeadline == null ? Colors.grey.shade500 : AppTheme.darkText, fontSize: 14),
                            ),
                            Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Priority', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedPriority,
                                items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                onChanged: (value) => setState(() => _selectedPriority = value!),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status State', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (value) => setState(() => _selectedStatus = value!),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Save Assignment Entry',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
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
