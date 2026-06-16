import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/assignment_card.dart';
import 'add_assignment_screen.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  Future<void> _openAddAssignment(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAssignmentScreen()),
    );
  }

  DateTime _deadlineFromData(Map<String, dynamic> data) {
    final value = data['deadline'];
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortAssignments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    docs.sort((a, b) {
      final aDeadline = a.data()['deadline'];
      final bDeadline = b.data()['deadline'];

      if (aDeadline is Timestamp && bDeadline is Timestamp) {
        return aDeadline.toDate().compareTo(bDeadline.toDate());
      }

      return 0;
    });

    return docs;
  }

  Future<void> _updateStatus(
    BuildContext context,
    String documentId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(documentId)
          .update({'status': status});

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Assignment marked as $status.')));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update assignment: $error'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Future<void> _deleteAssignment(
    BuildContext context,
    String documentId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(documentId)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Assignment deleted.')));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete assignment: $error'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view assignments.',
          style: TextStyle(color: AppTheme.grayText),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('assignments')
        .where('createdBy', isEqualTo: user.uid)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'My Assignments',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: AppTheme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Could not load assignments.\n\n${snapshot.error}',
                    style: TextStyle(color: AppTheme.danger),
                  ),
                ),
              ),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              SizedBox(height: 180),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }

        final docs = _sortAssignments(
          List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            snapshot.data?.docs ?? [],
          ),
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'My Assignments',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddAssignment(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Create, track, and update your academic tasks.',
              style: TextStyle(color: AppTheme.grayText, fontSize: 13),
            ),
            const SizedBox(height: 18),

            if (docs.isEmpty)
              Card(
                color: AppTheme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: AppTheme.grayText.withValues(alpha: 0.45),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No assignments yet',
                        style: TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap Add to create your first assignment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.grayText),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...docs.map((doc) {
                final data = doc.data();

                return AssignmentCard(
                  title: data['title']?.toString() ?? 'Untitled',
                  courseName: data['courseName']?.toString() ?? 'No Course',
                  description: data['description']?.toString() ?? '',
                  deadline: _deadlineFromData(data),
                  priority: data['priority']?.toString() ?? 'Medium',
                  status: data['status']?.toString() ?? 'Pending',
                  onStatusSelected: (status) {
                    _updateStatus(context, doc.id, status);
                  },
                  onDelete: () {
                    _deleteAssignment(context, doc.id);
                  },
                );
              }),
          ],
        );
      },
    );
  }
}
