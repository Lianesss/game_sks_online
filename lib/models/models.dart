import 'package:flutter/material.dart';

// ── User & Auth ──────────────────────────────────────────────────────────────

enum UserRole { client, marketing, admin, marketingAnalyst }

class User {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  int bonusBalance;
  int totalBonusEarned;
  LoyaltyStatus loyaltyStatus;
  int statusProgress; // 0-100
  int streak;         // daily check-in streak
  DateTime? lastCheckIn;
  bool checkedInToday;
  List<String> badgeIds;
  String league;      // Bronze, Silver, Gold, Platinum, Diamond
  int leaguePoints;
  String avatar;      // emoji avatar

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.bonusBalance = 0,
    this.totalBonusEarned = 0,
    this.loyaltyStatus = LoyaltyStatus.standard,
    this.statusProgress = 0,
    this.streak = 0,
    this.lastCheckIn,
    this.checkedInToday = false,
    this.badgeIds = const [],
    this.league = 'Bronze',
    this.leaguePoints = 0,
    this.avatar = '👤',
  });
}

enum LoyaltyStatus { standard, regular, premium, vip, superVip }

extension LoyaltyStatusExt on LoyaltyStatus {
  String get label => switch (this) {
    LoyaltyStatus.standard => 'Стандарт',
    LoyaltyStatus.regular => 'Постоянный',
    LoyaltyStatus.premium => 'Премиум',
    LoyaltyStatus.vip => 'VIP',
    LoyaltyStatus.superVip => 'Супер VIP',
  };
  Color get color => switch (this) {
    LoyaltyStatus.standard => Colors.grey,
    LoyaltyStatus.regular => const Color(0xFFCD7F32),
    LoyaltyStatus.premium => const Color(0xFFC0C0C0),
    LoyaltyStatus.vip => const Color(0xFFFFD700),
    LoyaltyStatus.superVip => const Color(0xFF00BFFF),
  };
}

// ── Bonus Transaction ─────────────────────────────────────────────────────────

class BonusTransaction {
  final String id;
  final int amount; // positive = earned, negative = spent
  final String source;
  final DateTime createdAt;
  final DateTime expiresAt;

  BonusTransaction({
    required this.id,
    required this.amount,
    required this.source,
    required this.createdAt,
    required this.expiresAt,
  });
}

// ── Quest ─────────────────────────────────────────────────────────────────────

enum QuestType { daily, seasonal }
enum QuestStatus { available, inProgress, completed, expired }

class Quest {
  final String id;
  final String title;
  final String description;
  final int rewardBonus;
  final QuestType type;
  QuestStatus status;
  final String icon;
  final DateTime? expiresAt;
  int progressCurrent;
  final int progressTotal;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardBonus,
    required this.type,
    this.status = QuestStatus.available,
    required this.icon,
    this.expiresAt,
    this.progressCurrent = 0,
    this.progressTotal = 1,
  });
}

// ── Achievement / Badge ───────────────────────────────────────────────────────

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isRare;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isRare = false,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

// ── Wheel Prize ───────────────────────────────────────────────────────────────

class WheelPrize {
  final String label;
  final int bonusAmount;
  final Color color;
  final double probability;
  final String? description;

  const WheelPrize({
    required this.label,
    required this.bonusAmount,
    required this.color,
    required this.probability,
    this.description,
  });
}

// ── Marketplace Prize ─────────────────────────────────────────────────────────

enum PrizeCategory { financial, partner, merch, charity, exclusive }

class MarketplacePrize {
  final String id;
  final String title;
  final String description;
  final int bonusCost;
  final PrizeCategory category;
  final String emoji;
  int? remainingCount;
  bool isPurchased;

  MarketplacePrize({
    required this.id,
    required this.title,
    required this.description,
    required this.bonusCost,
    required this.category,
    required this.emoji,
    this.remainingCount,
    this.isPurchased = false,
  });
}

extension PrizeCategoryExt on PrizeCategory {
  String get label => switch (this) {
    PrizeCategory.financial => 'Финансовые',
    PrizeCategory.partner => 'Партнёрские',
    PrizeCategory.merch => 'Мерч СКС',
    PrizeCategory.charity => 'Благотворительность',
    PrizeCategory.exclusive => 'Эксклюзивные',
  };
  Color get color => switch (this) {
    PrizeCategory.financial => const Color(0xFF43A047),
    PrizeCategory.partner => const Color(0xFF1E88E5),
    PrizeCategory.merch => const Color(0xFF8E24AA),
    PrizeCategory.charity => const Color(0xFFE53935),
    PrizeCategory.exclusive => const Color(0xFFFFB300),
  };
}

// ── Leaderboard ───────────────────────────────────────────────────────────────

class LeaderboardEntry {
  final int rank;
  final String avatar;
  final String pseudonym;
  final int bonusPoints;
  final String league;

  const LeaderboardEntry({
    required this.rank,
    required this.avatar,
    required this.pseudonym,
    required this.bonusPoints,
    required this.league,
  });
}

// ── Analytics ─────────────────────────────────────────────────────────────────

class AnalyticsData {
  final double dauMau;
  final int totalUsers;
  final int activeToday;
  final double questCompletionRate;
  final double prizeRedemptionRate;
  final List<DailyStats> weeklyStats;
  final Map<String, int> mechanicEngagement;

  const AnalyticsData({
    required this.dauMau,
    required this.totalUsers,
    required this.activeToday,
    required this.questCompletionRate,
    required this.prizeRedemptionRate,
    required this.weeklyStats,
    required this.mechanicEngagement,
  });
}

class DailyStats {
  final String day;
  final int dau;
  final int questsCompleted;
  final int bonusesAwarded;

  const DailyStats({
    required this.day,
    required this.dau,
    required this.questsCompleted,
    required this.bonusesAwarded,
  });
}
