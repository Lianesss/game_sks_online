import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bonus_card.dart';
import '../../widgets/streak_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _doCheckIn() async {
    final ok = context.read<AppProvider>().performDailyCheckIn();
    if (!mounted) return;
    if (ok) {
      _showCheckInDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Вы уже получили бонус сегодня!'),
            backgroundColor: Colors.orange),
      );
    }
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text('+5 бонусов!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent)),
            const SizedBox(height: 6),
            Text(
                'Серия: ${context.read<AppProvider>().currentUser!.streak} дней',
                style: const TextStyle(color: Color(0xFF545454))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отлично!'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryLight,
                child: Text(user.avatar,
                    style: const TextStyle(
                        fontSize: 26, color: AppTheme.textPrimary)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Привет, ${user.name.split(' ').first}!',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: user.loyaltyStatus.color
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(user.loyaltyStatus.label,
                            style: TextStyle(
                                fontSize: 11,
                                color: user.loyaltyStatus.color,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('Лига: ${user.league}',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF6B6B6B))),
                      ),
                    ]),
                  ],
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Color(0xFF6B6B6B)),
                  onPressed: () {}),
            ],
          ),
          const SizedBox(height: 20),

          // Bonus card
          BonusCard(
              balance: user.bonusBalance, totalEarned: user.totalBonusEarned),
          const SizedBox(height: 16),

          // Status progress
          _StatusProgress(user: user),
          const SizedBox(height: 16),

          // Daily Check-in
          StreakWidget(
            streak: user.streak,
            checkedInToday: user.checkedInToday,
            onCheckIn: _doCheckIn,
          ),
          const SizedBox(height: 20),

          // Quick Actions
          const Text('Быстрые действия',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: [
              _QuickAction(
                  icon: '🎯',
                  label: 'Квесты',
                  color: AppTheme.accent,
                  onTap: () => _navTo(context, 1)),
              _QuickAction(
                  icon: '🎡',
                  label: 'Колесо',
                  color: AppTheme.accentLight,
                  onTap: () => _navTo(context, 2)),
              _QuickAction(
                  icon: '🏆',
                  label: 'Каталог',
                  color: AppTheme.primary,
                  onTap: () => _navTo(context, 3)),
              _QuickAction(
                  icon: '📊',
                  label: 'Лидерборд',
                  color: AppTheme.accent.withValues(alpha: 0.95),
                  onTap: () => _navTo(context, 4)),
            ],
          ),
          const SizedBox(height: 20),

          // Recent transactions
          const Text('История бонусов',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111))),
          const SizedBox(height: 12),
          ...provider.transactions
              .take(5)
              .map((t) => _TransactionTile(transaction: t)),
        ],
      ),
    );
  }

  void _navTo(BuildContext context, int index) {
    // Tab navigation handled by MainShell
    Navigator.of(context).pushReplacementNamed('/home', arguments: index);
  }
}

class _StatusProgress extends StatelessWidget {
  final User user;
  const _StatusProgress({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Прогресс до ${_nextStatus(user.loyaltyStatus)}',
                  style:
                      const TextStyle(color: Color(0xFF545454), fontSize: 13)),
              Text('${user.statusProgress}%',
                  style: const TextStyle(
                      color: AppTheme.accent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: user.statusProgress / 100,
            backgroundColor: const Color(0xFFE0E0E0),
            progressColor: AppTheme.accent,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  String _nextStatus(LoyaltyStatus s) => switch (s) {
        LoyaltyStatus.standard => 'Постоянного',
        LoyaltyStatus.regular => 'Премиум',
        LoyaltyStatus.premium => 'VIP',
        LoyaltyStatus.vip => 'Супер VIP',
        LoyaltyStatus.superVip => 'Макс. статус',
      };
}

class _QuickAction extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 16, offset: Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111))),
                  const SizedBox(height: 2),
                  Text('Перейти',
                      style: TextStyle(
                          fontSize: 12, color: color.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final BonusTransaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppTheme.success.withValues(alpha: 0.15)
                  : AppTheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isPositive ? Icons.add_rounded : Icons.remove_rounded,
                color: isPositive ? AppTheme.success : AppTheme.error,
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.source,
                  style:
                      const TextStyle(color: Color(0xFF111111), fontSize: 13)),
              Text(_formatDate(transaction.createdAt),
                  style:
                      const TextStyle(color: Color(0xFF545454), fontSize: 11)),
            ],
          )),
          Text(
            '${isPositive ? '+' : ''}${transaction.amount} б.',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isPositive ? AppTheme.success : AppTheme.error),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day) {
      return 'Сегодня';
    }
    if (d.day == now.day - 1) {
      return 'Вчера';
    }
    return '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}
