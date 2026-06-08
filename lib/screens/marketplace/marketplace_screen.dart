import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  PrizeCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final filtered = _selectedCategory == null
        ? provider.prizes
        : provider.prizes
            .where((p) => p.category == _selectedCategory)
            .toList();

    return Column(
      children: [
        // Balance bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppTheme.cardBg,
          child: Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('Ваш баланс: ',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              Text('${user.bonusBalance} бонусов',
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),
        // Category filter
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              _CategoryChip(
                  label: 'Все',
                  color: AppTheme.textSecondary,
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null)),
              ...PrizeCategory.values.map((c) => _CategoryChip(
                    label: c.label,
                    color: c.color,
                    isSelected: _selectedCategory == c,
                    onTap: () => setState(() => _selectedCategory = c),
                  )),
            ],
          ),
        ),
        // Prizes grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) =>
                _PrizeCard(prize: filtered[i], userBalance: user.bonusBalance),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.label,
      required this.color,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : Colors.transparent, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _PrizeCard extends StatelessWidget {
  final MarketplacePrize prize;
  final int userBalance;
  const _PrizeCard({required this.prize, required this.userBalance});

  bool get canAfford => userBalance >= prize.bonusCost;

  void _purchase(BuildContext context) {
    if (prize.isPurchased) return;
    if (!canAfford) {
      final need = prize.bonusCost - userBalance;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(prize.title,
              style: const TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text('До приза осталось $need бонусов.',
                  style: const TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const Text('Получи их за квесты и ежедневный вход!',
                  style: TextStyle(color: AppTheme.accent),
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Понятно'))
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Купить ${prize.title}?',
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text('Спишется ${prize.bonusCost} бонусов',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final ok = context.read<AppProvider>().purchasePrize(prize.id);
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('✅ ${prize.title} куплен!'),
                      backgroundColor: AppTheme.success),
                );
              }
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _purchase(context),
      child: Container(
        decoration: BoxDecoration(
          color: prize.isPurchased
              ? AppTheme.success.withValues(alpha: 0.08)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: prize.isPurchased
                ? AppTheme.success.withValues(alpha: 0.3)
                : canAfford
                    ? prize.category.color.withValues(alpha: 0.2)
                    : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category stripe + emoji
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: prize.category.color.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                  child:
                      Text(prize.emoji, style: const TextStyle(fontSize: 42))),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prize.title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(prize.description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  if (prize.remainingCount != null)
                    Text('Осталось: ${prize.remainingCount}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: canAfford
                                ? prize.category.color.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prize.isPurchased
                                ? '✅ Куплен'
                                : '${prize.bonusCost} б.',
                            style: TextStyle(
                              color: prize.isPurchased
                                  ? AppTheme.success
                                  : canAfford
                                      ? prize.category.color
                                      : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
