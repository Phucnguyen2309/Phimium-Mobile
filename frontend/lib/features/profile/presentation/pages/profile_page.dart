import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Profile Page matching CineShorts Screen 4 design specification
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Card: Avatar, Name, Handle, Edit Button
              _buildUserHeader(context),
              const SizedBox(height: 14),

              // VIP Gold Member Badge Card
              _buildVipBadgeCard(),
              const SizedBox(height: 12),

              // Available Coin Balance Card
              _buildCoinBalanceCard(context),
              const SizedBox(height: 14),

              // Stats Row: 84 WATCHED | 16 SAVED | 4 DOWNLOADS
              _buildStatsRow(),
              const SizedBox(height: 16),

              // Menu Options List
              _buildMenuSection(context),
              const SizedBox(height: 20),

              // App Version & Device ID
              Center(
                child: Text(
                  'CineShorts v2.4.1 • Ultra-HD Micro Cinema\nDevice ID: CS-9942-X',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutralDark,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          // Avatar with gradient border
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 1.8),
              gradient: const LinearGradient(
                colors: [Color(0xFF3A2434), Color(0xFF1E1428)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Alex Rivera',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@alex_vibe',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutral,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Edit Profile Button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipBadgeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C220E), Color(0xFF191307)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.black,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'VIP GOLD MEMBER',
                  style: AppTextStyles.badgeText.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Expires Nov 28, 2026',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Available Coin Balance & Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE COIN BALANCE',
                style: AppTextStyles.badgeText.copyWith(
                  color: AppColors.neutral,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.warning,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '5-Day Streak',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Coin Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.secondary, size: 28),
              const SizedBox(width: 6),
              Text(
                '450',
                style: AppTextStyles.heading1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '= Unlocks next 22 micro-episodes',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutralLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily Claim Streak Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.secondary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Daily Claim Streak Active: +10 bonus today',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Big Red Button: Top-up / Buy Coins
          GestureDetector(
            onTap: () => context.push('/payment'),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Top-up / Buy Coins',
                    style: AppTextStyles.buttonText.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          _statBox('84', 'WATCHED'),
          _verticalDivider(),
          _statBox('16', 'SAVED'),
          _verticalDivider(),
          _statBox('4', 'DOWNLOADS'),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 32, color: AppColors.border);
  }

  Widget _buildMenuSection(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.receipt_long_rounded,
        title: 'Transaction History',
        subtitle: 'Recent coin purchases & episode unlocks',
        onTap: () => context.push('/payment'),
      ),
      _MenuItem(
        icon: Icons.history_rounded,
        title: 'Watch History',
        subtitle: 'Clear or view past 30 days',
        onTap: () => context.go('/bookmarks'),
      ),
      _MenuItem(
        icon: Icons.download_done_rounded,
        title: 'Downloads & Offline',
        subtitle: '3 Files (180 MB) • Offline Ready',
        trailingBadge: 'Offline Ready',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.tune_rounded,
        title: 'App Settings & Subtitles',
        subtitle: 'Video quality, captions, audio language',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.support_agent_rounded,
        title: 'Help & Customer Support',
        subtitle: '24/7 VIP chat concierge',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        title: 'Sign Out',
        subtitle: 'Safely log out of this device',
        isDestructive: true,
        onTap: () => context.go('/login'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.isDestructive
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isDestructive ? AppColors.error : AppColors.neutralLight,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: item.isDestructive ? AppColors.error : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutral,
                    fontSize: 11,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.trailingBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Text(
                          item.trailingBadge!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: item.isDestructive ? AppColors.error : AppColors.neutral,
                      size: 18,
                    ),
                  ],
                ),
                onTap: item.onTap,
              ),
              if (!isLast)
                const Divider(height: 1, indent: 64, endIndent: 16, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingBadge;
  final bool isDestructive;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingBadge,
    this.isDestructive = false,
    required this.onTap,
  });
}
