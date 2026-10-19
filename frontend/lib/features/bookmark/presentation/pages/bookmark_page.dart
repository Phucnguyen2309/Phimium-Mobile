import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// My Library / Watchlist Page matching CineShorts Screen 3 design
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  int _selectedTab = 0; // 0 = Watching, 1 = Saved

  final List<Map<String, dynamic>> _watchingList = [
    {
      'id': '1',
      'title': 'The Secret Billionaire Heir',
      'currentEp': 24,
      'totalEp': 85,
      'leftAt': '01:24',
      'progress': 0.65,
      'percent': '65%',
      'gradient': [Color(0xFF321A28), Color(0xFF1B0E16)],
      'icon': Icons.diamond_rounded,
    },
    {
      'id': '2',
      'title': 'Mistaken Identity Bride',
      'currentEp': 18,
      'totalEp': 60,
      'leftAt': '00:52',
      'progress': 0.30,
      'percent': '30%',
      'gradient': [Color(0xFF261933), Color(0xFF15101E)],
      'icon': Icons.favorite_rounded,
    },
    {
      'id': '3',
      'title': "Reborn as the Alpha's Queen",
      'currentEp': 52,
      'totalEp': 98,
      'leftAt': '01:45',
      'progress': 0.55,
      'percent': '55%',
      'gradient': [Color(0xFF381520), Color(0xFF1F101A)],
      'icon': Icons.pets_rounded,
    },
    {
      'id': '4',
      'title': 'Contract Marriage with CEO',
      'currentEp': 5,
      'totalEp': 80,
      'leftAt': '01:10',
      'progress': 0.10,
      'percent': '10%',
      'gradient': [Color(0xFF1E2836), Color(0xFF121922)],
      'icon': Icons.business_center_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: My Library •, Manage
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'My Library',
                        style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 6, bottom: 8),
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          color: AppColors.neutralLight,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Manage',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.neutralLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar: Watching (4) / Saved (12)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_circle_outline_rounded,
                                  color: _selectedTab == 0 ? Colors.white : AppColors.neutral,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Watching (4)',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: _selectedTab == 0 ? Colors.white : AppColors.neutral,
                                    fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_outline_rounded,
                                  color: _selectedTab == 1 ? Colors.white : AppColors.neutral,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Saved (12)',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: _selectedTab == 1 ? Colors.white : AppColors.neutral,
                                    fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                  ),
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

            // Cloud Synced Info Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.secondary,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '4 series in progress',
                      style: AppTextStyles.caption.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Cloud Synced',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutral,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List of In-progress Dramas
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                physics: const BouncingScrollPhysics(),
                itemCount: _watchingList.length,
                itemBuilder: (context, index) {
                  final drama = _watchingList[index];
                  return _buildLibraryItem(context, drama);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(BuildContext context, Map<String, dynamic> drama) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Poster Thumbnail
          GestureDetector(
            onTap: () => context.push('/drama/${drama['id']}'),
            child: Container(
              width: 80,
              height: 105,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: drama['gradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      drama['icon'] as IconData,
                      size: 32,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.6),
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
          const SizedBox(width: 12),

          // Content & Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drama['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelBold.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  'Ep. ${drama['currentEp']} of ${drama['totalEp']} • Left at ${drama['leftAt']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: drama['progress'] as double,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      drama['percent'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Action Buttons: RESUME + Trash
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push(
                        '/drama/${drama['id']}/episode/${drama['currentEp']}',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'RESUME',
                              style: AppTextStyles.buttonText.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.neutral,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
