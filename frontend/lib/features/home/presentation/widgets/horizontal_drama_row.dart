import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Reusable Horizontal Drama Series Row matching CineShorts design
class HorizontalDramaRow extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;
  final List<Map<String, dynamic>> items;

  const HorizontalDramaRow({
    super.key,
    required this.title,
    this.icon,
    this.showSeeAll = true,
    this.onSeeAllTap,
    required this.items,
  });

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
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(title, style: AppTextStyles.heading3),
                ],
              ),
              if (showSeeAll)
                GestureDetector(
                  onTap: onSeeAllTap ?? () => context.go('/search'),
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Horizontal List of Drama Posters
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildDramaCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDramaCard(BuildContext context, Map<String, dynamic> item) {
    final gradient = item['gradient'] as List<Color>? ??
        [const Color(0xFF241828), const Color(0xFF130E18)];

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => context.push('/drama/${item['id']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image Container
            Container(
              height: 175,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.8),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    // Decorative icon / illustration
                    Center(
                      child: Icon(
                        (item['icon'] as IconData?) ?? Icons.movie_filter_rounded,
                        size: 42,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),

                    // Dark overlay at bottom
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xB3000000),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Episode Count Badge top-left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          item['episodes'] as String? ?? '80 Eps',
                          style: AppTextStyles.badgeText.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),

                    // Center Play Button Overlay
                    Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Drama Title
            Text(
              item['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.dramaTitle.copyWith(fontSize: 12.5),
            ),
            const SizedBox(height: 2),

            // Rating & Views
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.secondary,
                  size: 13,
                ),
                const SizedBox(width: 2),
                Text(
                  item['rating'] as String? ?? '4.9',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                Text(
                  ' • ${item['views'] as String? ?? '2.1M'}',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
