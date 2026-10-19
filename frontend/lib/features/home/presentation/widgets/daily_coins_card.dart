import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Claim Daily Free Coins Banner matching CineShorts design
class DailyCoinsCard extends StatefulWidget {
  const DailyCoinsCard({super.key});

  @override
  State<DailyCoinsCard> createState() => _DailyCoinsCardState();
}

class _DailyCoinsCardState extends State<DailyCoinsCard> {
  bool _claimed = false;

  void _claimCoins() {
    if (_claimed) return;
    setState(() {
      _claimed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F1A08),
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              '+50 Coins claimed! Day 5 streak bonus active.',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.coinBannerGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Coin / Gift Box Icon in Gold Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Claim Daily Free Coins',
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Unlock next 2 micro-episodes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutralLight,
                  ),
                ),
              ],
            ),
          ),

          // CLAIM +50 Button
          GestureDetector(
            onTap: _claimCoins,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: _claimed ? null : AppColors.goldGradient,
                color: _claimed ? AppColors.surfaceLight : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _claimed
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                _claimed ? 'CLAIMED' : 'CLAIM +50',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _claimed ? AppColors.neutral : Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
