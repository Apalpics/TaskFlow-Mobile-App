import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please login to view progress.',
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
                    'Could not load progress.\n${snapshot.error}',
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
        final completed = docs
            .where(
              (doc) => (doc.data()['status']?.toString() ?? '') == 'Completed',
            )
            .length;
        final inProgress = docs
            .where(
              (doc) =>
                  (doc.data()['status']?.toString() ?? '') == 'In Progress',
            )
            .length;
        final pending = docs
            .where(
              (doc) => (doc.data()['status']?.toString() ?? '') == 'Pending',
            )
            .length;
        final overdue = docs.where((doc) => _isOverdue(doc.data())).length;

        final progress = total == 0 ? 0.0 : completed / total;
        final percent = (progress * 100).round();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
          children: [
            Text(
              'Progress Overview',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Monitor your academic task completion.',
              style: TextStyle(color: AppTheme.grayText, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Card(
              color: AppTheme.cardColor,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$percent% Completed',
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completed of $total assignments completed',
                      style: TextStyle(color: AppTheme.grayText, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: AppTheme.primaryBlue.withValues(
                          alpha: 0.12,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _ProgressStatCard(
                  title: 'Total',
                  value: '$total',
                  icon: Icons.assignment_outlined,
                  color: AppTheme.primaryBlue,
                ),
                _ProgressStatCard(
                  title: 'Pending',
                  value: '$pending',
                  icon: Icons.schedule_outlined,
                  color: AppTheme.warning,
                ),
                _ProgressStatCard(
                  title: 'In Progress',
                  value: '$inProgress',
                  icon: Icons.track_changes_outlined,
                  color: AppTheme.primaryBlue,
                ),
                _ProgressStatCard(
                  title: 'Completed',
                  value: '$completed',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.success,
                ),
                _ProgressStatCard(
                  title: 'Overdue',
                  value: '$overdue',
                  icon: Icons.warning_amber_outlined,
                  color: AppTheme.danger,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  const _ProgressStatCard({
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
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: AppTheme.grayText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
