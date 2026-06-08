import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import '../quests/quests_screen.dart';
import '../wheel/wheel_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../analytics/analytics_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 5);
  }

  List<_NavItem> _navItems(UserRole role) {
    final base = [
      const _NavItem(
          icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Главная'),
      const _NavItem(
          icon: Icons.assignment_outlined,
          activeIcon: Icons.assignment,
          label: 'Квесты'),
      const _NavItem(
          icon: Icons.casino_outlined,
          activeIcon: Icons.casino,
          label: 'Колесо'),
      const _NavItem(
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront,
          label: 'Каталог'),
      const _NavItem(
          icon: Icons.leaderboard_outlined,
          activeIcon: Icons.leaderboard,
          label: 'Рейтинг'),
    ];
    if (role == UserRole.marketing ||
        role == UserRole.admin ||
        role == UserRole.marketingAnalyst) {
      base.add(const _NavItem(
          icon: Icons.analytics_outlined,
          activeIcon: Icons.analytics,
          label: 'Аналитика'));
    }
    return base;
  }

  Widget _screen(UserRole role) {
    return switch (_selectedIndex) {
      0 => const HomeScreen(),
      1 => const QuestsScreen(),
      2 => const WheelScreen(),
      3 => const MarketplaceScreen(),
      4 => const LeaderboardScreen(),
      5 => const AnalyticsScreen(),
      _ => const HomeScreen(),
    };
  }

  String _title(int index, UserRole role) {
    final titles = [
      'SKS Quest',
      'Квесты',
      'Колесо фортуны',
      'Каталог призов',
      'Рейтинг',
      'Аналитика'
    ];
    return titles[index.clamp(0, titles.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final navItems = _navItems(user.role);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgLight,
        foregroundColor: AppTheme.textPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text('SKS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
            ),
            const SizedBox(width: 6),
            Text(_title(_selectedIndex, user.role),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111))),
          ],
        ),
        actions: [
          if (user.role == UserRole.marketing && _selectedIndex == 1)
            IconButton(
              icon:
                  const Icon(Icons.add_circle_outline, color: AppTheme.accent),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuestCreatorScreen())),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF545454)),
            color: AppTheme.cardBg,
            onSelected: (v) {
              if (v == 'logout') {
                provider.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'profile',
                  child: Row(children: [
                    Text(user.avatar, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(user.name,
                        style: const TextStyle(color: Color(0xFF111111))),
                  ])),
              const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    Icon(Icons.logout, color: Color(0xFF545454), size: 18),
                    SizedBox(width: 8),
                    Text('Выйти', style: TextStyle(color: Color(0xFF545454))),
                  ])),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
            key: ValueKey(_selectedIndex), child: _screen(user.role)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 72,
            child: Row(
              children: navItems.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final isSelected = _selectedIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? AppTheme.accent
                                  : const Color(0xFF7A7A7A),
                              size: 24),
                          const SizedBox(height: 3),
                          Text(item.label,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? AppTheme.accent
                                    : const Color(0xFF7A7A7A),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              )),
                          if (isSelected)
                            Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}
