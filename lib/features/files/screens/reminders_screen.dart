import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  String _reminderLabel(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(deadline.year, deadline.month, deadline.day);
    final diff = dueDay.difference(today).inDays;

    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due Today';
    if (diff == 1) return 'Due Tomorrow';
    return 'Upcoming';
  }

  Color _reminderColor(String label) {
    switch (label) {
      case 'Overdue':
        return AppTheme.danger;
      case 'Due Today':
        return AppTheme.warning;
      case 'Due Tomorrow':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.success;
    }
  }

  IconData _reminderIcon(String label) {
    switch (label) {
      case 'Overdue':
        return Icons.error_outline;
      case 'Due Today':
        return Icons.alarm_outlined;
      case 'Due Tomorrow':
        return Icons.schedule_outlined;
      default:
        return Icons.event_available_outlined;
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _activeAssignments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final active = docs.where((doc) {
      final data = doc.data();
      final status = data['status']?.toString() ?? 'Pending';
      final deadline = data['deadline'];

      return status != 'Completed' && deadline is Timestamp;
    }).toList();

    active.sort((a, b) {
      final aDate = (a.data()['deadline'] as Timestamp).toDate();
      final bDate = (b.data()['deadline'] as Timestamp).toDate();

      return aDate.compareTo(bDate);
    });

    return active;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Reminders')),
        body: Center(
          child: Text(
            'Please login to view reminders.',
            style: TextStyle(color: AppTheme.grayText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Reminders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .where('createdBy', isEqualTo: user.uid)
            .snapshots(),
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
                      'Could not load reminders.\n${snapshot.error}',
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

          final docs = _activeAssignments(snapshot.data?.docs ?? []);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
            children: [
              Text(
                'Deadline Reminders',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Check which assignments need attention.',
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
                          Icons.notifications_none_outlined,
                          size: 64,
                          color: AppTheme.grayText.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No reminders right now',
                          style: TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Completed assignments are not shown here.',
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
                  final deadline = (data['deadline'] as Timestamp).toDate();
                  final label = _reminderLabel(deadline);
                  final color = _reminderColor(label);

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
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_reminderIcon(label), color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title']?.toString() ?? 'Untitled',
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
                                  '${data['courseName']?.toString() ?? 'No Course'} - ${DateFormat.yMMMd().format(deadline)}',
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
