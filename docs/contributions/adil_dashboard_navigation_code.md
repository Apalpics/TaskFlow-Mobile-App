# Dashboard UI, Theme Design, and Navigation Module

**File:** `docs/contributions/adil_dashboard_navigation_code.md`  
**Contributor:** Adil Emadeldin  
**Module:** Dashboard UI, Theme Design, Navigation  
**Project:** TaskFlow – Smart Academic Task and Collaboration Management System  
**Course:** INFO 4335 Mobile Application Development  

---

## 1. Contribution Summary

This file documents my contribution to the **Dashboard UI, Theme Design, and Navigation** module of the TaskFlow app. My responsibilities include:

- Designing the main dashboard screen layout
- Building reusable summary cards (total assignments, pending, completed)
- Building upcoming deadline cards
- Suggesting navigation integration with `main_navigation_screen.dart`
- Ensuring all UI follows the TaskFlow design style using `AppTheme`

All code below uses **static sample data only**. The final integrator will connect real Firestore data later.

---

## 2. Dashboard Design Explanation

The dashboard is the first screen students see after login. It is designed to give a quick overview of:

- **Summary stats** — total assignments, pending tasks, completed tasks
- **Upcoming deadlines** — sorted by nearest due date
- **Quick access** — navigation to Assignment, Group, Files, and Progress screens

Design decisions:
- Uses `AppTheme.primaryBlue` (`#3D52A0`) for header and active elements
- White and light gray cards with rounded corners (`BorderRadius.circular(16)`)
- Bottom navigation bar with 4 tabs
- Clean, minimal layout — no clutter, easy to scan

---

## 3. Dashboard Screen Code

**File path suggestion:** `lib/features/dashboard/screens/dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/deadline_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Summary Cards Row
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryCards(),
              const SizedBox(height: 28),

              // Upcoming Deadlines
              Text(
                'Upcoming Deadlines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 12),
              _buildUpcomingDeadlines(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 👋',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.grayText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adil Emadeldin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.primaryBlue,
          child: const Icon(Icons.person, color: Colors.white, size: 22),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    // Static sample data — integrator will replace with Firestore data
    final List<Map<String, dynamic>> summaryData = [
      {
        'label': 'Total',
        'value': '8',
        'icon': Icons.assignment,
        'color': AppTheme.primaryBlue,
      },
      {
        'label': 'Pending',
        'value': '3',
        'icon': Icons.hourglass_empty,
        'color': AppTheme.warning,
      },
      {
        'label': 'Completed',
        'value': '5',
        'icon': Icons.check_circle_outline,
        'color': AppTheme.success,
      },
    ];

    return Row(
      children: summaryData
          .map(
            (data) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SummaryCard(
                  label: data['label'],
                  value: data['value'],
                  icon: data['icon'],
                  color: data['color'],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildUpcomingDeadlines() {
    // Static sample data — integrator will replace with Firestore stream
    final List<Map<String, dynamic>> deadlines = [
      {
        'title': 'HCI Prototype Report',
        'course': 'INFO 4335',
        'deadline': 'Today',
        'priority': 'High',
        'status': 'In Progress',
      },
      {
        'title': 'Database ER Diagram',
        'course': 'INFO 2303',
        'deadline': 'Tomorrow',
        'priority': 'Medium',
        'status': 'Pending',
      },
      {
        'title': 'Mobile App Proposal',
        'course': 'INFO 4335',
        'deadline': 'June 20',
        'priority': 'Low',
        'status': 'Pending',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deadlines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = deadlines[index];
        return DeadlineCard(
          title: item['title'],
          course: item['course'],
          deadline: item['deadline'],
          priority: item['priority'],
          status: item['status'],
        );
      },
    );
  }
}
```

---

## 4. Summary Card Widget

**File path suggestion:** `lib/features/dashboard/widgets/summary_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.grayText,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. Deadline Card Widget

**File path suggestion:** `lib/features/dashboard/widgets/deadline_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DeadlineCard extends StatelessWidget {
  final String title;
  final String course;
  final String deadline;
  final String priority;
  final String status;

  const DeadlineCard({
    super.key,
    required this.title,
    required this.course,
    required this.deadline,
    required this.priority,
    required this.status,
  });

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Priority color indicator
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _priorityColor(),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                  ),
                ),
              ],
            ),
          ),

          // Deadline badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  deadline,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.grayText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Integration Notes for `main_navigation_screen.dart`

The final integrator should update `main_navigation_screen.dart` to include the Dashboard as the first tab. Suggested changes:

```dart
// In main_navigation_screen.dart

import '../../features/dashboard/screens/dashboard_screen.dart';
// ... other screen imports

// Screens list:
final List<Widget> _screens = [
  const DashboardScreen(),       // index 0 — Dashboard
  const AssignmentsScreen(),     // index 1 — Assignments
  const GroupTasksScreen(),      // index 2 — Group
  const FilesScreen(),           // index 3 — Files
  const ProgressScreen(),        // index 4 — Progress (optional)
];

// Bottom NavigationBar:
NavigationBar(
  selectedIndex: _currentIndex,
  onDestinationSelected: (index) {
    setState(() => _currentIndex = index);
  },
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: 'Group',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: 'Files',
    ),
  ],
)
```
---

## 7. Testing Notes

Before submitting, manually test the following:

| Test | Expected Result |
|------|----------------|
| Dashboard screen loads | No errors, all widgets visible |
| Summary cards display | 3 cards shown: Total, Pending, Completed |
| Deadline cards display | 3 sample deadline cards visible |
| Priority color indicators | High = red, Medium = orange, Low = green |
| Bottom navigation taps | Each tab switches screen correctly |
| Scroll behavior | Dashboard scrolls without overflow errors |
| Different screen sizes | Layout is not broken on small/large phones |

> All tests above use static data only. Real Firestore integration testing is handled by the final integrator.

---

*Contribution by Adil Emadeldin — TaskFlow, INFO 4335, IIUM KICT*
