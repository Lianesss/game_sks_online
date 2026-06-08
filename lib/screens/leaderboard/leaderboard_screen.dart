import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.bgLight,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppTheme.textPrimary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.accent,
            tabs: const [
              Tab(text: '🏆 Лидерборд'),
              Tab(text: '🎖️ Достижения')
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [_LeaderboardTab(), _AchievementsTab()],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final board = provider.leaderboard;
    final userEntry = board.firstWhere(
        (e) => e.pseudonym == '${user.name.split(' ').first} К.',
        orElse: () => LeaderboardEntry(
            rank: 4,
            avatar: user.avatar,
            pseudonym: user.name,
            bonusPoints: user.bonusBalance,
            league: user.league));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current user position
        _UserPositionCard(entry: userEntry, isCurrentUser: true),
        const SizedBox(height: 16),
        // League info
        _LeagueInfoBar(league: user.league),
        const SizedBox(height: 16),
        // Anonymous notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.privacy_tip_outlined,
                color: AppTheme.textSecondary, size: 16),
            SizedBox(width: 8),
            Expanded(
                child: Text('Лидерборд анонимный: ФИО и данные не раскрываются',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12))),
          ]),
        ),
        const SizedBox(height: 16),
        // Board
        ...board.asMap().entries.map((e) {
          final entry = e.value;
          final isCurrent = entry.pseudonym == user.name;
          return _LeaderboardTile(entry: entry, isCurrentUser: isCurrent);
        }),
      ],
    );
  }
}

class _UserPositionCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  const _UserPositionCard({required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(entry.avatar, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ваша позиция',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text(entry.pseudonym,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('#${entry.rank}',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            Text('${entry.bonusPoints} б.',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}

class _LeagueInfoBar extends StatelessWidget {
  final String league;
  const _LeagueInfoBar({required this.league});

  Color get _leagueColor => switch (league) {
        'Bronze' => AppTheme.bronze,
        'Silver' => AppTheme.silver,
        'Gold' => AppTheme.gold,
        'Platinum' => AppTheme.platinum,
        'Diamond' => AppTheme.diamond,
        _ => Colors.grey,
      };

  String get _leagueName => switch (league) {
        'Bronze' => 'Бронза',
        'Silver' => 'Серебро',
        'Gold' => 'Золото',
        'Platinum' => 'Платина',
        'Diamond' => 'Бриллиант',
        _ => league,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _leagueColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _leagueColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text('🏅', style: TextStyle(fontSize: 22, color: _leagueColor)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Текущая лига: $_leagueName',
                style: TextStyle(
                    color: _leagueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const Text('Топ 10% в конце месяца — повышение в лиге!',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ]),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  const _LeaderboardTile({required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final rankColor = entry.rank == 1
        ? AppTheme.gold
        : entry.rank == 2
            ? AppTheme.silver
            : entry.rank == 3
                ? AppTheme.bronze
                : AppTheme.textSecondary;
    final rankIcon = entry.rank == 1
        ? '🥇'
        : entry.rank == 2
            ? '🥈'
            : entry.rank == 3
                ? '🥉'
                : '#${entry.rank}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.primary.withValues(alpha: 0.2)
            : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCurrentUser ? AppTheme.primary : Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 36,
              child: Text(rankIcon,
                  style: TextStyle(
                      fontSize: entry.rank <= 3 ? 22 : 16,
                      color: rankColor,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 10),
          Text(entry.avatar, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.pseudonym,
                  style: TextStyle(
                      color:
                          isCurrentUser ? Colors.white : AppTheme.textPrimary,
                      fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14)),
              Text(entry.league,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ]),
          ),
          Text('${entry.bonusPoints} б.',
              style: TextStyle(
                  color:
                      isCurrentUser ? AppTheme.accent : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Achievements Tab ──────────────────────────────────────────────────────────

class _AchievementsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final unlocked = provider.achievements.where((a) => a.isUnlocked).toList();
    final locked = provider.achievements.where((a) => !a.isUnlocked).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Получено: ${unlocked.length}/${provider.achievements.length}',
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        const Text('Нажмите на карточку, чтобы увидеть подробности',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        if (unlocked.isNotEmpty) ...[
          const Text('🎖️ Разблокировано',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children:
                unlocked.map((a) => _AchievementCard(achievement: a)).toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (locked.isNotEmpty) ...[
          const Text('🔒 Ещё не получено',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children:
                locked.map((a) => _AchievementCard(achievement: a)).toList(),
          ),
        ],
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(unlocked ? achievement.emoji : '🔒',
                style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            Text(achievement.title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(achievement.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
            if (achievement.isRare)
              Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('⭐ Редкий бейдж',
                      style: TextStyle(color: AppTheme.accent, fontSize: 12))),
            if (unlocked && achievement.unlockedAt != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Получен: ${_fmt(achievement.unlockedAt!)}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11))),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'))
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: unlocked
              ? (achievement.isRare
                  ? AppTheme.accent.withValues(alpha: 0.1)
                  : AppTheme.cardBg)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: unlocked
                  ? (achievement.isRare
                      ? AppTheme.accent.withValues(alpha: 0.4)
                      : Colors.white10)
                  : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(unlocked ? achievement.emoji : '🔒',
                        style: TextStyle(
                            fontSize: 30,
                            color: unlocked ? null : AppTheme.textSecondary)),
                    if (achievement.isRare)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text('⭐', style: TextStyle(fontSize: 16)),
                      )
                  ],
                ),
                const SizedBox(height: 8),
                Text(achievement.title,
                    style: TextStyle(
                        color: unlocked ? Colors.white : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(achievement.description,
                    style: TextStyle(
                        color: unlocked
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondary.withValues(alpha: 0.8),
                        fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            if (!unlocked)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Становится доступно после разблокировки',
                    style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        fontSize: 10),
                    textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
