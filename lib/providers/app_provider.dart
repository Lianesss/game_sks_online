import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'dart:math';

class AppProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  // ── Current user ──────────────────────────────────────────────────────────
  User? _currentUser;
  User? get currentUser => _currentUser;

  // ── Wheel spin state ──────────────────────────────────────────────────────
  int _weeklySpinsUsed = 0;
  int _bonusSpinsUsed = 0;
  DateTime? _bonusSpinsDate;
  static const int maxDailyBonusSpins = 2;

  int get weeklySpinsUsed => _weeklySpinsUsed;
  int get bonusSpinsUsed {
    _ensureDailyBonusSpinState();
    return _bonusSpinsUsed;
  }

  bool get hasFreeWeeklySpin => _weeklySpinsUsed < 1;
  bool get canBonusSpin {
    _ensureDailyBonusSpinState();
    return _bonusSpinsUsed < maxDailyBonusSpins;
  }

  int get bonusSpinsRemaining {
    _ensureDailyBonusSpinState();
    return maxDailyBonusSpins - _bonusSpinsUsed;
  }

  // ── Data ──────────────────────────────────────────────────────────────────
  List<Quest> _quests = [];
  List<Quest> get quests => _quests;

  List<Achievement> _achievements = [];
  List<Achievement> get achievements => _achievements;

  List<MarketplacePrize> _prizes = [];
  List<MarketplacePrize> get prizes => _prizes;

  List<LeaderboardEntry> _leaderboard = [];
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  List<BonusTransaction> _transactions = [];
  List<BonusTransaction> get transactions => _transactions;

  AnalyticsData? _analytics;
  AnalyticsData? get analytics => _analytics;

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────────────────

  void login(String phone, UserRole role) {
    _currentUser = User(
      id: _uuid.v4(),
      name: _nameForRole(role),
      phone: phone,
      role: role,
      bonusBalance: role == UserRole.client ? 1250 : 0,
      totalBonusEarned: role == UserRole.client ? 3480 : 0,
      loyaltyStatus: LoyaltyStatus.regular,
      statusProgress: 62,
      streak: 5,
      league: 'Silver',
      leaguePoints: 1250,
      avatar: _avatarForRole(role),
      badgeIds: ['first_loan', 'streak_7'],
    );
    _initData();
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  String _nameForRole(UserRole role) => switch (role) {
        UserRole.client => 'Алексей К.',
        UserRole.marketing => 'Менеджер Маркетинга',
        UserRole.admin => 'Администратор',
        UserRole.marketingAnalyst => 'Аналитик',
      };

  String _avatarForRole(UserRole role) => switch (role) {
        UserRole.client => '🦊',
        UserRole.marketing => '📊',
        UserRole.admin => '🛡️',
        UserRole.marketingAnalyst => '📈',
      };

  // ─────────────────────────────────────────────────────────────────────────
  // DATA INIT (seed data per ТЗ)
  // ─────────────────────────────────────────────────────────────────────────

  void _initData() {
    _initQuests();
    _initAchievements();
    _initPrizes();
    _initLeaderboard();
    _initTransactions();
    _initAnalytics();
  }

  void _initQuests() {
    final now = DateTime.now();
    _quests = [
      // Daily
      Quest(
          id: 'q1',
          title: 'Проверить статус залога',
          description:
              'Откройте раздел «Мои займы» и просмотрите статус залога',
          rewardBonus: 10,
          type: QuestType.daily,
          icon: '🔍',
          expiresAt: DateTime(now.year, now.month, now.day, 23, 59),
          progressTotal: 1),
      Quest(
          id: 'q2',
          title: 'Прочитать статью о золоте',
          description: 'Прочитайте обучающую статью в разделе «Знания»',
          rewardBonus: 15,
          type: QuestType.daily,
          icon: '📖',
          expiresAt: DateTime(now.year, now.month, now.day, 23, 59),
          progressTotal: 1),
      Quest(
          id: 'q3',
          title: 'Посмотреть калькулятор займа',
          description: 'Откройте калькулятор и рассчитайте условия займа',
          rewardBonus: 10,
          type: QuestType.daily,
          icon: '🧮',
          expiresAt: DateTime(now.year, now.month, now.day, 23, 59),
          progressTotal: 1),
      Quest(
          id: 'q4',
          title: 'Пригласить друга',
          description: 'Отправьте реферальную ссылку другу',
          rewardBonus: 200,
          type: QuestType.daily,
          icon: '👥',
          expiresAt: DateTime(now.year, now.month, now.day, 23, 59),
          progressTotal: 1),
      // Seasonal
      Quest(
          id: 'qs1',
          title: 'Летняя акция: 3 шага',
          description:
              'Выполните 3 действия за неделю и получите эксклюзивный бейдж',
          rewardBonus: 500,
          type: QuestType.seasonal,
          icon: '☀️',
          expiresAt: DateTime(now.year, 8, 31),
          progressTotal: 3,
          progressCurrent: 1),
      Quest(
          id: 'qs2',
          title: 'День ломбарда',
          description: 'Специальный квест в честь дня рождения СКС',
          rewardBonus: 1000,
          type: QuestType.seasonal,
          icon: '🎂',
          expiresAt: DateTime(now.year, 9, 15),
          progressTotal: 5,
          progressCurrent: 2),
    ];
  }

  void _initAchievements() {
    _achievements = [
      Achievement(
          id: 'first_loan',
          title: 'Первый займ',
          description: 'Оформили первый займ в СКС',
          emoji: '🥇',
          isUnlocked: true,
          unlockedAt: DateTime.now().subtract(const Duration(days: 90))),
      Achievement(
          id: 'streak_7',
          title: 'Серия 7 дней',
          description: 'Входили 7 дней подряд',
          emoji: '🔥',
          isUnlocked: true,
          unlockedAt: DateTime.now().subtract(const Duration(days: 3))),
      Achievement(
          id: 'streak_14',
          title: 'Серия 14 дней',
          description: 'Входили 14 дней подряд',
          emoji: '⚡',
          isRare: false),
      Achievement(
          id: 'streak_30',
          title: 'Постоянный гость',
          description: 'Серия 30 дней — вы легенда!',
          emoji: '👑',
          isRare: true),
      Achievement(
          id: 'bonus_1000',
          title: '1000 бонусов',
          description: 'Накопили 1000 бонусов',
          emoji: '💰',
          isUnlocked: true,
          unlockedAt: DateTime.now().subtract(const Duration(days: 20))),
      Achievement(
          id: 'bonus_10000',
          title: '10 000 бонусов',
          description: 'Накопили 10 000 бонусов',
          emoji: '💎',
          isRare: true),
      Achievement(
          id: 'early_bird',
          title: 'Ранняя пташка',
          description: 'Посетили офис до 10:00',
          emoji: '🐦',
          isRare: true),
      Achievement(
          id: 'on_time',
          title: 'Точно в срок',
          description: 'Выкупили залог в день окончания периода',
          emoji: '⏱️'),
      Achievement(
          id: 'loan_5',
          title: 'Пять займов',
          description: 'Оформили 5-й займ',
          emoji: '🎯'),
      Achievement(
          id: 'year_member',
          title: 'Год с СКС',
          description: 'Год в программе лояльности',
          emoji: '🎊',
          isRare: true),
      Achievement(
          id: 'referral_3',
          title: 'Амбассадор',
          description: 'Пригласили 3 друзей',
          emoji: '🌟',
          isRare: true),
      Achievement(
          id: 'wheel_lucky',
          title: 'Счастливчик',
          description: 'Выиграли редкий приз в Колесе',
          emoji: '🎡'),
    ];
  }

  void _initPrizes() {
    _prizes = [
      // Financial
      MarketplacePrize(
          id: 'p1',
          title: 'Скидка 5% на проценты',
          description: 'Скидка на проценты следующего займа',
          bonusCost: 300,
          category: PrizeCategory.financial,
          emoji: '💸'),
      MarketplacePrize(
          id: 'p2',
          title: 'Хранение залога 7 дней',
          description: 'Бесплатное хранение залога на 7 дней',
          bonusCost: 200,
          category: PrizeCategory.financial,
          emoji: '🔒'),
      MarketplacePrize(
          id: 'p3',
          title: 'Экспресс-обслуживание',
          description: 'Приоритетная очередь в офисе',
          bonusCost: 150,
          category: PrizeCategory.financial,
          emoji: '⚡'),
      // Partner
      MarketplacePrize(
          id: 'p4',
          title: 'Сертификат Wildberries 500₽',
          description: 'Подарочный сертификат Wildberries',
          bonusCost: 500,
          category: PrizeCategory.partner,
          emoji: '🛍️',
          remainingCount: 50),
      MarketplacePrize(
          id: 'p5',
          title: 'Сертификат OZON 500₽',
          description: 'Подарочный сертификат OZON',
          bonusCost: 500,
          category: PrizeCategory.partner,
          emoji: '📦',
          remainingCount: 30),
      MarketplacePrize(
          id: 'p6',
          title: 'Сертификат в кинотеатр',
          description: 'Билеты в кино на 2 персоны',
          bonusCost: 800,
          category: PrizeCategory.partner,
          emoji: '🎬',
          remainingCount: 15),
      // Merch
      MarketplacePrize(
          id: 'p7',
          title: 'Футболка СКС',
          description: 'Фирменная футболка с логотипом СКС',
          bonusCost: 1000,
          category: PrizeCategory.merch,
          emoji: '👕',
          remainingCount: 100),
      MarketplacePrize(
          id: 'p8',
          title: 'Термокружка СКС',
          description: 'Фирменная термокружка 350мл',
          bonusCost: 600,
          category: PrizeCategory.merch,
          emoji: '☕',
          remainingCount: 200),
      MarketplacePrize(
          id: 'p9',
          title: 'Стикерпак',
          description: 'Набор фирменных стикеров СКС',
          bonusCost: 100,
          category: PrizeCategory.merch,
          emoji: '🎨'),
      // Charity
      MarketplacePrize(
          id: 'p10',
          title: 'Благотворительность',
          description: 'Перевести бонусы в фонд помощи животным',
          bonusCost: 50,
          category: PrizeCategory.charity,
          emoji: '❤️'),
      // Exclusive
      MarketplacePrize(
          id: 'p11',
          title: 'Встреча с топ-менеджментом',
          description: 'Эксклюзивная встреча с руководством СКС',
          bonusCost: 5000,
          category: PrizeCategory.exclusive,
          emoji: '🤝',
          remainingCount: 3),
      MarketplacePrize(
          id: 'p12',
          title: 'Закрытое мероприятие',
          description: 'Приглашение на VIP-мероприятие СКС',
          bonusCost: 3000,
          category: PrizeCategory.exclusive,
          emoji: '🎭',
          remainingCount: 10),
    ];
  }

  void _initLeaderboard() {
    _leaderboard = [
      const LeaderboardEntry(
          rank: 1,
          avatar: '🦁',
          pseudonym: 'Лев_Удачи',
          bonusPoints: 4820,
          league: 'Diamond'),
      const LeaderboardEntry(
          rank: 2,
          avatar: '🐯',
          pseudonym: 'Тигр_СКС',
          bonusPoints: 4310,
          league: 'Diamond'),
      const LeaderboardEntry(
          rank: 3,
          avatar: '🐻',
          pseudonym: 'Медведь99',
          bonusPoints: 3890,
          league: 'Platinum'),
      const LeaderboardEntry(
          rank: 4,
          avatar: '🦊',
          pseudonym: 'Алексей К.',
          bonusPoints: 1250,
          league: 'Silver'),
      const LeaderboardEntry(
          rank: 5,
          avatar: '🐺',
          pseudonym: 'Волк_Золота',
          bonusPoints: 3200,
          league: 'Gold'),
      const LeaderboardEntry(
          rank: 6,
          avatar: '🦅',
          pseudonym: 'Орёл_Бонус',
          bonusPoints: 2950,
          league: 'Gold'),
      const LeaderboardEntry(
          rank: 7,
          avatar: '🐬',
          pseudonym: 'Дельфин22',
          bonusPoints: 2640,
          league: 'Gold'),
      const LeaderboardEntry(
          rank: 8,
          avatar: '🦋',
          pseudonym: 'Бабочка_VIP',
          bonusPoints: 2310,
          league: 'Silver'),
      const LeaderboardEntry(
          rank: 9,
          avatar: '🦝',
          pseudonym: 'Енот_Хитрый',
          bonusPoints: 1980,
          league: 'Silver'),
      const LeaderboardEntry(
          rank: 10,
          avatar: '🐨',
          pseudonym: 'Коала_Тихая',
          bonusPoints: 1720,
          league: 'Silver'),
    ];
  }

  void _initTransactions() {
    final now = DateTime.now();
    _transactions = [
      BonusTransaction(
          id: '1',
          amount: 5,
          source: 'Ежедневный вход',
          createdAt: now.subtract(const Duration(hours: 2)),
          expiresAt: now.add(const Duration(days: 365))),
      BonusTransaction(
          id: '2',
          amount: 15,
          source: 'Квест: Статья о золоте',
          createdAt: now.subtract(const Duration(days: 1)),
          expiresAt: now.add(const Duration(days: 364))),
      BonusTransaction(
          id: '3',
          amount: 50,
          source: 'Серия 7 дней',
          createdAt: now.subtract(const Duration(days: 3)),
          expiresAt: now.add(const Duration(days: 362))),
      BonusTransaction(
          id: '4',
          amount: -150,
          source: 'Термокружка СКС',
          createdAt: now.subtract(const Duration(days: 5)),
          expiresAt: now.add(const Duration(days: 360))),
      BonusTransaction(
          id: '5',
          amount: 1200,
          source: 'Оплата процентов по займу',
          createdAt: now.subtract(const Duration(days: 10)),
          expiresAt: now.add(const Duration(days: 355))),
      BonusTransaction(
          id: '6',
          amount: 100,
          source: 'Колесо фортуны',
          createdAt: now.subtract(const Duration(days: 12)),
          expiresAt: now.add(const Duration(days: 353))),
    ];
  }

  void _initAnalytics() {
    _analytics = const AnalyticsData(
      dauMau: 0.32,
      totalUsers: 18420,
      activeToday: 5894,
      questCompletionRate: 0.43,
      prizeRedemptionRate: 0.28,
      weeklyStats: [
        DailyStats(
            day: 'Пн', dau: 4200, questsCompleted: 1890, bonusesAwarded: 24300),
        DailyStats(
            day: 'Вт', dau: 4800, questsCompleted: 2100, bonusesAwarded: 28100),
        DailyStats(
            day: 'Ср', dau: 5100, questsCompleted: 2340, bonusesAwarded: 31200),
        DailyStats(
            day: 'Чт', dau: 4900, questsCompleted: 2200, bonusesAwarded: 29800),
        DailyStats(
            day: 'Пт', dau: 5600, questsCompleted: 2580, bonusesAwarded: 35400),
        DailyStats(
            day: 'Сб', dau: 6100, questsCompleted: 2800, bonusesAwarded: 38900),
        DailyStats(
            day: 'Вс', dau: 5894, questsCompleted: 2640, bonusesAwarded: 36200),
      ],
      mechanicEngagement: {
        'Daily Check-in': 78,
        'Квесты': 43,
        'Колесо': 31,
        'Каталог призов': 28,
        'Лидерборд': 19,
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────────

  bool performDailyCheckIn() {
    if (_currentUser == null || _currentUser!.checkedInToday) return false;
    const bonus = 5;
    _currentUser!.bonusBalance += bonus;
    _currentUser!.totalBonusEarned += bonus;
    _currentUser!.streak += 1;
    _currentUser!.checkedInToday = true;
    _currentUser!.lastCheckIn = DateTime.now();
    _addTransaction(bonus, 'Ежедневный вход');
    // Streak bonuses
    if (_currentUser!.streak == 7) {
      _addTransaction(50, 'Серия 7 дней');
    }
    if (_currentUser!.streak == 14) {
      _addTransaction(150, 'Серия 14 дней');
    }
    if (_currentUser!.streak == 30) {
      _addTransaction(500, 'Серия 30 дней');
    }
    notifyListeners();
    return true;
  }

  bool completeQuest(String questId) {
    final q = _quests.firstWhere((q) => q.id == questId,
        orElse: () => throw Exception());
    if (q.status == QuestStatus.completed) return false;
    q.progressCurrent = q.progressTotal;
    q.status = QuestStatus.completed;
    _currentUser!.bonusBalance += q.rewardBonus;
    _currentUser!.totalBonusEarned += q.rewardBonus;
    _addTransaction(q.rewardBonus, 'Квест: ${q.title}');
    notifyListeners();
    return true;
  }

  bool purchasePrize(String prizeId) {
    final prize = _prizes.firstWhere((p) => p.id == prizeId);
    if (_currentUser!.bonusBalance < prize.bonusCost) return false;
    _currentUser!.bonusBalance -= prize.bonusCost;
    prize.isPurchased = true;
    if (prize.remainingCount != null) {
      prize.remainingCount = prize.remainingCount! - 1;
    }
    _addTransaction(-prize.bonusCost, 'Покупка: ${prize.title}');
    notifyListeners();
    return true;
  }

  void _ensureDailyBonusSpinState() {
    final now = DateTime.now();
    if (_bonusSpinsDate == null || !_isSameDay(now, _bonusSpinsDate!)) {
      _bonusSpinsDate = now;
      _bonusSpinsUsed = 0;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  int spinWheel(bool isFreeOrBonusPaid) {
    if (isFreeOrBonusPaid) {
      _weeklySpinsUsed++;
    } else {
      _ensureDailyBonusSpinState();
      if (!canBonusSpin || _currentUser!.bonusBalance < 50) return -1;
      _currentUser!.bonusBalance -= 50;
      _bonusSpinsUsed++;
      _addTransaction(-50, 'Прокрутка колеса');
    }
    // Random prize
    final prizes = [10, 25, 50, 100, 200, 500];
    final weights = [30, 25, 20, 15, 8, 2];
    final rand = Random().nextInt(100);
    int acc = 0, won = 10;
    for (int i = 0; i < prizes.length; i++) {
      acc += weights[i];
      if (rand < acc) {
        won = prizes[i];
        break;
      }
    }
    _currentUser!.bonusBalance += won;
    _currentUser!.totalBonusEarned += won;
    _addTransaction(won, 'Колесо фортуны');
    notifyListeners();
    return won;
  }

  /// Возвращает ИНДЕКС выигранного приза (от 0 до 5) для корректной анимации.
  int spinWheelIndex(bool isFreeOrBonusPaid) {
    if (isFreeOrBonusPaid) {
      _weeklySpinsUsed++;
    } else {
      _ensureDailyBonusSpinState();
      if (!canBonusSpin || _currentUser!.bonusBalance < 50) return -1;
      _currentUser!.bonusBalance -= 50;
      _bonusSpinsUsed++;
      _addTransaction(-50, 'Прокрутка колеса');
    }

    // Логика выбора индекса (соответствует весам из вашего метода spinWheel)
    // 10 б. (0) - 30%, 25 б. (1) - 25%, 50 б. (2) - 20%,
    // 100 б. (3) - 15%, 200 б. (4) - 8%, 500 б. (5) - 2%
    final prizes = [10, 25, 50, 100, 200, 500];
    final weights = [30, 25, 20, 15, 8, 2];

    final rand = Random().nextInt(100);
    int acc = 0;
    int wonIndex = 0;

    for (int i = 0; i < weights.length; i++) {
      acc += weights[i];
      if (rand < acc) {
        wonIndex = i;
        break;
      }
    }

    // ОБЯЗАТЕЛЬНО начисляем бонус по индексу, который выпал
    final wonAmount = prizes[wonIndex];
    _currentUser!.bonusBalance += wonAmount;
    _currentUser!.totalBonusEarned += wonAmount;
    _addTransaction(wonAmount, 'Колесо фортуны');

    notifyListeners();

    return wonIndex; // Возвращаем индекс 0-5
  }

  void _addTransaction(int amount, String source) {
    _transactions.insert(
        0,
        BonusTransaction(
          id: _uuid.v4(),
          amount: amount,
          source: source,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 365)),
        ));
  }

  void createQuest(
      {required String title,
      required String description,
      required int reward,
      required String icon}) {
    final q = Quest(
      id: _uuid.v4(),
      title: title,
      description: description,
      rewardBonus: reward,
      type: QuestType.seasonal,
      icon: icon,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      progressTotal: 1,
    );
    _quests.add(q);
    notifyListeners();
  }
}
