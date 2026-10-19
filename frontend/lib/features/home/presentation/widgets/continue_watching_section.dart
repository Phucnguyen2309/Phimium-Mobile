import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Continue Watching Section with horizontal progress cards
class ContinueWatchingSection extends StatelessWidget {
  const ContinueWatchingSection({super.key});

  static const List<Map<String, dynamic>> items = [
    {
      'id': '2',
      'title': 'Mistaken Identity Bride',
      'currentEp': 24,
      'totalEp': 60,
      'progress': 0.75,
      'percentText': '75%',
      'bgGradient': [Color(0xFF2E1C2B), Color(0xFF161020)],
      'icon': Icons.favorite_border_rounded,
    },
    {
      'id': '3',
      'title': 'Return of the God of War',
      'currentEp': 8,
      'totalEp': 92,
      'progress': 0.30,
      'percentText': '30%',
      'bgGradient': [Color(0xFF142436), Color(0xFF0F1522)],
      'icon': Icons.shield_outlined,
    },
    {
      'id': '4',
      'title': 'Cold CEO Hidden Heiress',
      'currentEp': 15,
      'totalEp': 45,
      'progress': 0.50,
      'percentText': '50%',
      'bgGradient': [Color(0xFF261D12), Color(0xFF131018)],
      'icon': Icons.diamond_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Continue Watching',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/bookmarks'),
                child: Row(
                  children: [
                    Text(
                      'History',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutralLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.neutralLight,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal List
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => context.push('/drama/${item['id']}/episode/${item['currentEp']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail container
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.8),
                gradient: LinearGradient(
                  colors: item['bgGradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    // Icon decorative background
                    Center(
                      child: Icon(
                        item['icon'] as IconData,
                        size: 40,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),

                    // Center Play Button
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    // Progress bar at the bottom of the thumbnail
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 3.5,
                        color: Colors.white.withValues(alpha: 0.2),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: item['progress'] as double,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Drama Title
            Text(
              item['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.dramaTitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 3),

            // Episode Info & Progress %
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ep ${item['currentEp']} / ${item['totalEp']}',
                  style: AppTextStyles.episodeCount,
                ),
                Text(
                  item['percentText'] as String,
                  style: AppTextStyles.episodeCount.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
