import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final data = provider.analytics!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Дашборд аналитики',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const Text('Только для аналитиков и маркетинга',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 20),
          // KPI cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _KpiCard(
                  label: 'DAU/MAU',
                  value: '${(data.dauMau * 100).toStringAsFixed(0)}%',
                  icon: '📊',
                  sublabel: 'Цель: >30%',
                  color: const Color(0xFF1565C0)),
              _KpiCard(
                  label: 'Активных сегодня',
                  value: '${(data.activeToday / 1000).toStringAsFixed(1)}K',
                  icon: '👥',
                  sublabel:
                      'из ${(data.totalUsers / 1000).toStringAsFixed(0)}K',
                  color: const Color(0xFF2E7D32)),
              _KpiCard(
                  label: 'Квесты (конверсия)',
                  value:
                      '${(data.questCompletionRate * 100).toStringAsFixed(0)}%',
                  icon: '🎯',
                  sublabel: 'Цель: >40%',
                  color: const Color(0xFF6A1B9A)),
              _KpiCard(
                  label: 'Призы (конверсия)',
                  value:
                      '${(data.prizeRedemptionRate * 100).toStringAsFixed(0)}%',
                  icon: '🏆',
                  sublabel: 'Цель: >30%',
                  color: const Color(0xFF4E342E)),
            ],
          ),
          const SizedBox(height: 24),

          // DAU chart
          const Text('DAU за неделю',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16)),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 7000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                        data.weeklyStats[value.toInt()].day,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  )),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Colors.white10, strokeWidth: 0.5),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.weeklyStats
                    .asMap()
                    .entries
                    .map((e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.dau.toDouble(),
                              color: AppTheme.primary,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            )
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mechanic engagement
          const Text('Вовлечённость по механикам',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: data.mechanicEngagement.entries.map((e) {
                final pct = e.value / 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                            Text('${e.value}%',
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation(_colorForPct(pct)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Quest performance table
          const Text('Эффективность квестов (7 дней)',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16)),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2)
              },
              children: [
                _tableRow(['Квест', 'Выполнений', 'Конверсия'], isHeader: true),
                _tableRow(['Статус залога', '2,340', '43%']),
                _tableRow(['Статья о золоте', '1,890', '35%']),
                _tableRow(['Калькулятор займа', '2,100', '39%']),
                _tableRow(['Пригласить друга', '280', '5%']),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Color _colorForPct(double pct) {
    if (pct > 0.6) return AppTheme.success;
    if (pct > 0.3) return AppTheme.accent;
    return AppTheme.error;
  }

  TableRow _tableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)))
          : null,
      children: cells
          .map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(c,
                    style: TextStyle(
                        color: isHeader
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: isHeader ? 11 : 13,
                        fontWeight:
                            isHeader ? FontWeight.normal : FontWeight.normal)),
              ))
          .toList(),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final String sublabel;
  final Color color;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.sublabel,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          Text(sublabel,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
