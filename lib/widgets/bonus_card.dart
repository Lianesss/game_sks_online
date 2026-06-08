import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BonusCard extends StatelessWidget {
  final int balance;
  final int totalEarned;
  const BonusCard(
      {super.key, required this.balance, required this.totalEarned});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 22, offset: Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -12,
            child: Text(
              'SKS',
              style: TextStyle(
                fontSize: 88,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Баланс бонусов',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$balance',
                      style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111))),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('бонусов',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppTheme.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: AppTheme.accent, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Всего заработано: $totalEarned б.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('1 б. = 1 ₽',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11, color: AppTheme.textPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
