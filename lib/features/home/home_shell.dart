import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../calendar/calendar_page.dart';
import '../analytics/analytics_page.dart';
import '../settings/settings_page.dart';
import 'home_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  Widget _page() {
    return switch (index) {
      0 => const HomePage(key: ValueKey('home')),
      1 => const CalendarPage(key: ValueKey('calendar')),
      2 => const AnalyticsPage(key: ValueKey('analytics')),
      _ => const SettingsPage(key: ValueKey('settings')),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page(),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: GlassCard(
          radius: 23,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(0, Icons.home_rounded, 'خانه'),
              _item(1, Icons.calendar_month_rounded, 'تقویم'),
              _item(2, Icons.bar_chart_rounded, 'گزارش'),
              _item(3, Icons.settings_rounded, 'تنظیمات'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final active = index == i;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index != i) setState(() => index = i);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? AppColors.blue : AppColors.muted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w500,
                  color: active ? AppColors.blue : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
