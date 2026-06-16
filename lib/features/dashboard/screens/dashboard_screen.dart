import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  bool _isOverdue(Map<String, dynamic> data) {
    final deadline = data['deadline'];

    if (deadline is! Timestamp) {
      return false;
    }

    final status = data['status']?.toString() ?? 'Pending';

    if (status == 'Completed') {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = deadline.toDate();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return dueDay.isBefore(today);
  }

  String _deadlineLabel(Map<String, dynamic> data) {
    final deadline = data['deadline'];

    if (deadline is! Timestamp) {
      return 'No deadline';
    }

    final dueDate = deadline.toDate();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dueDay.difference(today).inDays;

    if (diff < 0) {
      return 'Overdue';
    }

    if (diff == 0) {
      return 'Due today';
    }

    if (diff == 1) {
      return 'Due tomorrow';
    }

    if (diff <= 7) {
      return 'Due in $diff days';
    }

    return DateFormat.yMMMd().format(dueDate);
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.danger;
      case 'Medium':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _upcomingAssignments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered = docs.where((doc) {
      final status = doc.data()['status']?.toString() ?? 'Pending';
      final deadline = doc.data()['deadline'];

      return status != 'Completed' && deadline is Timestamp;
    }).toList();

    filtered.sort((a, b) {
      final aDate = (a.data()['deadline'] as Timestamp).toDate();
      final bDate = (b.data()['deadline'] as Timestamp).toDate();

      return aDate.compareTo(bDate);
    });

    return filtered.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName;
    final displayName = name == null || name.trim().isEmpty ? 'Student' : name;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view dashboard.',
          style: TextStyle(color: AppTheme.grayText),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                    'Could not load dashboard.\n${snapshot.error}',
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

        final total = docs.length;
        final pending = docs
            .where(
              (doc) => (doc.data()['status']?.toString() ?? '') == 'Pending',
            )
            .length;
        final completed = docs
            .where(
              (doc) => (doc.data()['status']?.toString() ?? '') == 'Completed',
            )
            .length;
        final overdue = docs.where((doc) => _isOverdue(doc.data())).length;
        final upcoming = _upcomingAssignments(docs);

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $displayName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Stay organized and keep your academic tasks on track.',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.school, color: Colors.white, size: 38),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _SummaryCard(
                    title: 'Total',
                    value: '$total',
                    icon: Icons.assignment,
                    color: AppTheme.primaryBlue,
                  ),
                  _SummaryCard(
                    title: 'Pending',
                    value: '$pending',
                    icon: Icons.access_time,
                    color: AppTheme.warning,
                  ),
                  _SummaryCard(
                    title: 'Completed',
                    value: '$completed',
                    icon: Icons.check_circle,
                    color: AppTheme.success,
                  ),
                  _SummaryCard(
                    title: 'Overdue',
                    value: '$overdue',
                    icon: Icons.warning,
                    color: AppTheme.danger,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Upcoming Deadlines',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                Card(
                  color: AppTheme.cardColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No upcoming deadlines right now.',
                            style: TextStyle(color: AppTheme.grayText),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...upcoming.map((doc) {
                  final data = doc.data();
                  final priority = data['priority']?.toString() ?? 'Medium';
                  final color = _priorityColor(priority);

                  return _DeadlineCard(
                    title: data['title']?.toString() ?? 'Untitled',
                    course: data['courseName']?.toString() ?? 'No Course',
                    time: _deadlineLabel(data),
                    priority: priority,
                    color: color,
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: AppTheme.grayText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({
    required this.title,
    required this.course,
    required this.time,
    required this.priority,
    required this.color,
  });

  final String title;
  final String course;
  final String time;
  final String priority;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.assignment_outlined, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$course - $time',
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                priority,
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
  }
}
