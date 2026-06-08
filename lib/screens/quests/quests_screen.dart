import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen>
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
        // Tab bar
        Container(
          color: AppTheme.bgLight,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppTheme.textPrimary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.accent,
            indicatorWeight: 2,
            tabs: const [Tab(text: '🎯 Ежедневные'), Tab(text: '🌟 Сезонные')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _DailyQuestsList(),
              _SeasonalQuestsList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyQuestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final dailyQuests =
        provider.quests.where((q) => q.type == QuestType.daily).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Daily quest info banner
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Text('ℹ️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Выберите квест и выполните его — получите бонусы! Сброс в 00:00',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13))),
            ],
          ),
        ),
        ...dailyQuests.map((q) => _QuestCard(quest: q)),
      ],
    );
  }
}

class _SeasonalQuestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final seasonal =
        provider.quests.where((q) => q.type == QuestType.seasonal).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Text('⏰', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Сезонные квесты ограничены по времени. Не упустите шанс!',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13))),
            ],
          ),
        ),
        ...seasonal.map((q) => _QuestCard(quest: q, isSeasonal: true)),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  final bool isSeasonal;
  const _QuestCard({required this.quest, this.isSeasonal = false});

  void _completeQuest(BuildContext context) {
    final ok = context.read<AppProvider>().completeQuest(quest.id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Квест выполнен! +${quest.rewardBonus} бонусов'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == QuestStatus.completed;
    final progress = quest.progressTotal > 1
        ? quest.progressCurrent / quest.progressTotal
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.success.withValues(alpha: 0.08)
            : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCompleted
                ? AppTheme.success.withValues(alpha: 0.3)
                : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(quest.icon, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quest.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 3),
                    Text(quest.description,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('+${quest.rewardBonus} б.',
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                  if (quest.expiresAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(_timeLeft(quest.expiresAt!),
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 10)),
                    ),
                ],
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${quest.progressCurrent}/${quest.progressTotal}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _completeQuest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSeasonal ? Colors.purple : AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Выполнить',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                  SizedBox(width: 6),
                  Text('Выполнено',
                      style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _timeLeft(DateTime expires) {
    final diff = expires.difference(DateTime.now());
    if (diff.inDays > 0) return 'Ещё ${diff.inDays} д.';
    if (diff.inHours > 0) return 'Ещё ${diff.inHours} ч.';
    return 'Скоро закончится';
  }
}

// Marketing Quest Creator
class QuestCreatorScreen extends StatefulWidget {
  const QuestCreatorScreen({super.key});

  @override
  State<QuestCreatorScreen> createState() => _QuestCreatorScreenState();
}

class _QuestCreatorScreenState extends State<QuestCreatorScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController(text: '50');
  String _selectedIcon = '🎯';

  final _icons = ['🎯', '📖', '🧮', '👥', '🔍', '💎', '🌟', '⚡', '🏆', '🎁'];

  void _save() {
    if (_titleCtrl.text.isEmpty) return;
    context.read<AppProvider>().createQuest(
          title: _titleCtrl.text,
          description: _descCtrl.text,
          reward: int.tryParse(_rewardCtrl.text) ?? 50,
          icon: _selectedIcon,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Квест создан и опубликован!'),
          backgroundColor: AppTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
          title: const Text('Создать квест'),
          backgroundColor: AppTheme.bgDark,
          actions: [
            TextButton(
                onPressed: _save,
                child: const Text('Сохранить',
                    style: TextStyle(color: AppTheme.accent))),
          ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Название квеста', _titleCtrl),
          const SizedBox(height: 12),
          _field('Описание', _descCtrl, maxLines: 3),
          const SizedBox(height: 12),
          _field('Награда (бонусов)', _rewardCtrl, isNumber: true),
          const SizedBox(height: 20),
          const Text('Иконка',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _icons
                .map((icon) => GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? AppTheme.accent.withValues(alpha: 0.2)
                              : AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _selectedIcon == icon
                                  ? AppTheme.accent
                                  : Colors.transparent),
                        ),
                        child: Center(
                            child: Text(icon,
                                style: const TextStyle(fontSize: 24))),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.cardBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}
