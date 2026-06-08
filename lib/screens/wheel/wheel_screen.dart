import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  late Animation<double> _spinAnim;
  bool _spinning = false;
  double _currentAngle = 0;

  final _prizes = const [
    WheelPrize(
        label: '10 б.',
        bonusAmount: 10,
        color: Color(0xFF1565C0),
        probability: 0.30),
    WheelPrize(
        label: '25 б.',
        bonusAmount: 25,
        color: Color(0xFF6A1B9A),
        probability: 0.25),
    WheelPrize(
        label: '50 б.',
        bonusAmount: 50,
        color: Color(0xFF2E7D32),
        probability: 0.20),
    WheelPrize(
        label: '100 б.',
        bonusAmount: 100,
        color: Color(0xFF4E342E),
        probability: 0.15),
    WheelPrize(
        label: '200 б.',
        bonusAmount: 200,
        color: Color(0xFFE65100),
        probability: 0.08),
    WheelPrize(
        label: '500 б.',
        bonusAmount: 500,
        color: Color(0xFFB71C1C),
        probability: 0.02),
  ];

  @override
  void initState() {
    super.initState();
    _spinCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _spinAnim = CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _spin(bool isFree) {
    if (_spinning) return;
    final provider = context.read<AppProvider>();

    if (!isFree) {
      if (!provider.canBonusSpin) {
        _showPaidSpinLimitWarning();
        return;
      }
      if (provider.currentUser!.bonusBalance < 50) {
        _showInsufficientBalanceWarning();
        return;
      }
    }

    final int winningIndex = provider.spinWheelIndex(isFree);
    if (winningIndex < 0) return;

    setState(() => _spinning = true);

    final int totalPrizes = _prizes.length;
    final double segmentAngle = (2 * math.pi) / totalPrizes;
    final double baseAngle = -math.pi / 2 - (segmentAngle / 2);

    // 1. Угол середины нашего призового сектора с учётом верхнего указателя
    final double targetSectorAngle =
        baseAngle + (winningIndex * segmentAngle) + (segmentAngle / 2);

    // 2. Считаем угол: (полные обороты) - (цель) + (смещение стрелки 270 градусов)
    // 10 полных оборотов для красоты
    const double extraSpins = 10 * 2 * math.pi;
    final double end = extraSpins - targetSectorAngle + (3 * math.pi / 2);

    _spinAnim = Tween<double>(begin: _currentAngle, end: end).animate(
      CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOutCubic),
    );

    final winningPrize = _prizes[winningIndex];

    _spinCtrl.reset();
    _spinCtrl.forward().then((_) {
      if (!mounted) return;
      final currentAngle = end % (2 * math.pi);
      setState(() {
        _spinning = false;
        _currentAngle = currentAngle;
      });
      _showWinDialog(winningPrize);
    });
  }

  void _showPaidSpinLimitWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Платные прокрутки сегодня закончились. Возвращайтесь завтра.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInsufficientBalanceWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Недостаточно бонусов для платной прокрутки.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWinDialog(WheelPrize prize) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text('Вы выиграли!',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            const SizedBox(height: 4),
            Text(prize.label,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('+${prize.bonusAmount} бонусов',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отлично! 🎊')),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Колесо фортуны',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                Text('Баланс: ${user.bonusBalance} б.',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ]),
              GestureDetector(
                onTap: _showProbabilities,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24)),
                  child: const Icon(Icons.info_outline,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Wheel
          SizedBox(
            height: 300,
            width: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _spinAnim,
                  builder: (_, __) => Transform.rotate(
                    angle: _spinAnim.value,
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _WheelPainter(prizes: _prizes),
                    ),
                  ),
                ),
                // Center circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.bgDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: const Center(
                      child: Text('SKS',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                ),
                // Arrow pointer (top)
                Positioned(
                  top: 0,
                  child: CustomPaint(
                    size: const Size(24, 28),
                    painter: _ArrowPainter(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Spin buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _spinning || !provider.hasFreeWeeklySpin
                      ? null
                      : () => _spin(true),
                  icon: const Text('🎡', style: TextStyle(fontSize: 18)),
                  label: Text(provider.hasFreeWeeklySpin
                      ? 'Бесплатно!'
                      : 'Использовано'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.hasFreeWeeklySpin
                        ? AppTheme.accent
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _spinning || !provider.canBonusSpin || user.bonusBalance < 50
                      ? null
                      : () => _spin(false),
                  icon: const Text('💎', style: TextStyle(fontSize: 18)),
                  label: const Text('50 бонусов'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.canBonusSpin && user.bonusBalance >= 50
                        ? AppTheme.primary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.canBonusSpin
                ? 'Платных прокруток сегодня: ${provider.bonusSpinsRemaining}/2'
                : 'Платных прокруток сегодня больше нет — возвращайтесь завтра',
            style: TextStyle(
              color: provider.canBonusSpin
                  ? AppTheme.textSecondary
                  : AppTheme.error,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),

          // Prizes list
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Возможные призы',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                ..._prizes.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: p.color,
                                borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 10),
                        Text(p.label,
                            style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14)),
                        const Spacer(),
                        Text('${(p.probability * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ]),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProbabilities() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Вероятности призов',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text(
                'Согласно требованиям комплаенса, все вероятности прозрачны:',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            ..._prizes.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: p.color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(p.label,
                            style:
                                const TextStyle(color: AppTheme.textPrimary))),
                    Text('${(p.probability * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold)),
                  ]),
                )),
            const SizedBox(height: 8),
            const Text(
                '⚠️ Данная механика не является азартной игрой или лотереей. Призы — бонусные баллы программы лояльности.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<WheelPrize> prizes;
  _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * math.pi / prizes.length;
    final baseAngle = -math.pi / 2 - (segmentAngle / 2);

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = baseAngle + i * segmentAngle;

      final paint = Paint()
        ..color = prizes[i].color
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, segmentAngle, true, paint);

      // Border
      final borderPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, segmentAngle, true, borderPaint);

      // Label (смещаем текст на половину сегмента)
      final labelAngle = startAngle + segmentAngle / 2;
      final labelR = radius * 0.65;
      final tx = center.dx + labelR * math.cos(labelAngle);
      final ty = center.dy + labelR * math.sin(labelAngle);

      canvas.save();
      canvas.translate(tx, ty);
      // Поворачиваем текст под нужным углом
      canvas.rotate(labelAngle + math.pi / 2);

      final tp = TextPainter(
        text: TextSpan(
            text: prizes[i].label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Rim
    final rimPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
