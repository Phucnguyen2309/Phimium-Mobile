import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Top 10 Binge-Worthy Section with Giant Number Badges
class TopRankedSection extends StatelessWidget {
  const TopRankedSection({super.key});

  static const List<Map<String, dynamic>> rankedItems = [
    {
      'rank': 1,
      'id': '101',
      'title': "Reborn as the Alpha's Queen",
      'episodes': '98 Episodes',
      'badge': 'TRENDING',
      'badgeColor': AppColors.primary,
      'gradient': [Color(0xFF381520), Color(0xFF1F101A)],
      'icon': Icons.pets_rounded,
    },
    {
      'rank': 2,
      'id': '102',
      'title': 'Contract Marriage with CEO',
      'episodes': '80 Episodes',
      'badge': 'VIP',
      'badgeColor': AppColors.secondary,
      'gradient': [Color(0xFF2E2210), Color(0xFF1A150D)],
      'icon': Icons.business_center_rounded,
    },
    {
      'rank': 3,
      'id': '103',
      'title': "The Billionaire's Hidden Heiress",
      'episodes': '72 Episodes',
      'badge': 'HOT',
      'badgeColor': AppColors.primary,
      'gradient': [Color(0xFF162534), Color(0xFF0F1822)],
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'rank': 4,
      'id': '104',
      'title': 'Revenge of the Abandoned CEO',
      'episodes': '95 Episodes',
      'badge': 'TOP 10',
      'badgeColor': Color(0xFF8E8E93),
      'gradient': [Color(0xFF261933), Color(0xFF15101E)],
      'icon': Icons.psychology_rounded,
    },
    {
      'rank': 5,
      'id': '105',
      'title': 'Alpha King\'s Secret Mate',
      'episodes': '68 Episodes',
      'badge': 'NEW',
      'badgeColor': AppColors.primaryLight,
      'gradient': [Color(0xFF341724), Color(0xFF1A0E15)],
      'icon': Icons.nightlight_round,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Top 10 Binge-Worthy',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Text(
                  'RANKED TODAY',
                  style: AppTextStyles.badgeText.copyWith(
                    color: AppColors.neutralLight,
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal list with giant rank numbers
        SizedBox(
          height: 245,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: rankedItems.length,
            itemBuilder: (context, index) {
              final item = rankedItems[index];
              return _buildRankedCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRankedCard(BuildContext context, Map<String, dynamic> item) {
    final rank = item['rank'] as int;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () => context.push('/drama/${item['id']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Card with Giant Number overlay
            SizedBox(
              height: 185,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Poster background container
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.8),
                        gradient: LinearGradient(
                          colors: item['gradient'] as List<Color>,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          children: [
                            // Atmospheric decorative icon
                            Center(
                              child: Icon(
                                item['icon'] as IconData,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),

                            // Dark vignette overlay at bottom
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0x99000000),
                                      Color(0xF0000000),
                                    ],
                                    stops: [0.3, 0.7, 1.0],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            // Top badge
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (item['badgeColor'] as Color).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['badge'] as String,
                                  style: AppTextStyles.badgeText.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Giant stylized rank number in bottom-left
                  Positioned(
                    left: 6,
                    bottom: -6,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: rank == 1
                              ? [const Color(0xFFFF5E7E), const Color(0xFFFF2A4D)]
                              : rank == 2
                                  ? [const Color(0xFFFFD44D), const Color(0xFFFFB800)]
                                  : [Colors.white, const Color(0xFF8E8E93)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      child: Text(
                        '$rank',
                        style: AppTextStyles.rankNumber.copyWith(
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.9),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Drama Title
            Text(
              item['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.dramaTitle,
            ),
            const SizedBox(height: 2),

            // Episodes
            Text(
              item['episodes'] as String,
              style: AppTextStyles.episodeCount,
            ),
          ],
        ),
      ),
    );
  }
}
