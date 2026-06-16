import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<_NavPage> _pages = const [
    _NavPage(
      title: 'Dashboard',
      icon: Icons.dashboard_rounded,
      child: _DashboardPreview(),
    ),
    _NavPage(
      title: 'Assignments',
      icon: Icons.assignment_rounded,
      child: _SimpleModulePage(
        title: 'Assignments',
        subtitle: 'Create, view, edit, and track academic assignments.',
        icon: Icons.assignment_rounded,
      ),
    ),
    _NavPage(
      title: 'Progress',
      icon: Icons.pie_chart_rounded,
      child: _SimpleModulePage(
        title: 'Progress Tracking',
        subtitle: 'Monitor completed, pending, and overdue academic tasks.',
        icon: Icons.pie_chart_rounded,
      ),
    ),
    _NavPage(
      title: 'Groups',
      icon: Icons.groups_rounded,
      child: _SimpleModulePage(
        title: 'Group Projects',
        subtitle: 'Manage shared responsibilities and group project tasks.',
        icon: Icons.groups_rounded,
      ),
    ),
    _NavPage(
      title: 'Files',
      icon: Icons.folder_rounded,
      child: _SimpleModulePage(
        title: 'Files',
        subtitle: 'Organize assignment files and academic resources.',
        icon: Icons.folder_rounded,
      ),
    ),
    _NavPage(
      title: 'Profile',
      icon: Icons.person_rounded,
      child: _SimpleModulePage(
        title: 'Profile',
        subtitle: 'View account information and manage app settings.',
        icon: Icons.person_rounded,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.title),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: currentPage.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: _pages
            .map(
              (page) => NavigationDestination(
                icon: Icon(page.icon),
                selectedIcon: Icon(page.icon, color: AppTheme.primaryBlue),
                label: page.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavPage {
  final String title;
  final IconData icon;
  final Widget child;

  const _NavPage({
    required this.title,
    required this.icon,
    required this.child,
  });
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _GreetingCard(),
        SizedBox(height: 18),
        _SummaryGrid(),
        SizedBox(height: 18),
        _SectionTitle(title: 'Upcoming Deadlines'),
        SizedBox(height: 12),
        _AssignmentPreviewCard(
          title: 'Mobile App Project',
          course: 'INFO 4335',
          date: 'Due tomorrow',
          priority: 'High',
          color: AppTheme.danger,
        ),
        SizedBox(height: 12),
        _AssignmentPreviewCard(
          title: 'Database Lab Report',
          course: 'INFO 2303',
          date: 'Due in 3 days',
          priority: 'Medium',
          color: AppTheme.warning,
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Stay organized and keep your academic tasks on track.',
                  style: TextStyle(
                    color: Color(0xFFE8ECFF),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 46,
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: const [
        _SummaryCard(
          title: 'Total',
          value: '8',
          icon: Icons.assignment_rounded,
          color: AppTheme.primaryBlue,
        ),
        _SummaryCard(
          title: 'Pending',
          value: '5',
          icon: Icons.schedule_rounded,
          color: AppTheme.warning,
        ),
        _SummaryCard(
          title: 'Completed',
          value: '2',
          icon: Icons.check_circle_rounded,
          color: AppTheme.success,
        ),
        _SummaryCard(
          title: 'Overdue',
          value: '1',
          icon: Icons.warning_rounded,
          color: AppTheme.danger,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.grayText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.darkText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _AssignmentPreviewCard extends StatelessWidget {
  final String title;
  final String course;
  final String date;
  final String priority;
  final Color color;

  const _AssignmentPreviewCard({
    required this.title,
    required this.course,
    required this.date,
    required this.priority,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.assignment_outlined, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text('$course • $date'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            priority,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleModulePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SimpleModulePage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.grayText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
