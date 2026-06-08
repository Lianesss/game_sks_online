import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StreakWidget extends StatelessWidget {
  final int streak;
  final bool checkedInToday;
  final VoidCallback onCheckIn;

  const StreakWidget(
      {super.key,
      required this.streak,
      required this.checkedInToday,
      required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final milestones = [7, 14, 30];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ежедневный вход',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Серия: $streak ${_dayWord(streak)}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (!checkedInToday)
                GestureDetector(
                  onTap: onCheckIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text('+5 б.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                )
              else
                const Icon(Icons.check_circle,
                    color: AppTheme.success, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: milestones.map((m) {
              final reached = streak >= m;
              final bonus = m == 7
                  ? 50
                  : m == 14
                      ? 150
                      : 500;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: reached
                        ? AppTheme.accent.withValues(alpha: 0.14)
                        : const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: reached ? AppTheme.accent : Colors.transparent,
                        width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Text('$m дней',
                          style: TextStyle(
                              color: reached
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('+$bonus б.',
                          style: TextStyle(
                              color: reached
                                  ? AppTheme.accent
                                  : const Color(0xFF9E9E9E),
                              fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Text('🧊 Заморозить серию за 100 б.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  String _dayWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) {
      return 'день';
    }
    if (n % 10 >= 2 && n % 10 <= 4 && !(n % 100 >= 12 && n % 100 <= 14)) {
      return 'дня';
    }
    return 'дней';
  }
}
