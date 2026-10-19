import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Discover / Search Page matching CineShorts Screen 2 design
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  static const List<String> _categories = [
    'All',
    'Revenge',
    'CEO & Billionaire',
    'Werewolf & Romance',
    'Martial Arts',
    'Historical',
  ];

  static const List<Map<String, dynamic>> _dramas = [
    {
      'id': '1',
      'title': "The Billionaire's Hidden Heiress",
      'episodes': '88 Ep',
      'tag': 'Romance',
      'rating': '4.9',
      'views': '2.4M',
      'badge': 'HOT',
      'badgeColor': AppColors.primary,
      'gradient': [Color(0xFF381520), Color(0xFF1F101A)],
      'icon': Icons.diamond_rounded,
    },
    {
      'id': '2',
      'title': 'Revenge of the Abandoned CEO',
      'episodes': '95 Ep',
      'tag': 'Revenge',
      'rating': '4.8',
      'views': '890K',
      'badge': 'TOP 10',
      'badgeColor': Color(0xFF8E8E93),
      'gradient': [Color(0xFF261933), Color(0xFF15101E)],
      'icon': Icons.psychology_rounded,
    },
    {
      'id': '3',
      'title': "Alpha King's Secret Mate",
      'episodes': '72 Ep',
      'tag': 'Werewolf',
      'rating': '4.9',
      'views': '1.1M',
      'badge': 'VIP',
      'badgeColor': AppColors.secondary,
      'gradient': [Color(0xFF321A28), Color(0xFF1B0E16)],
      'icon': Icons.nightlight_round,
    },
    {
      'id': '4',
      'title': 'Return of the Silent Tycoon',
      'episodes': '64 Ep',
      'tag': 'Billionaire',
      'rating': '4.7',
      'views': '650K',
      'badge': null,
      'badgeColor': null,
      'gradient': [Color(0xFF182838), Color(0xFF101924)],
      'icon': Icons.business_center_rounded,
    },
    {
      'id': '5',
      'title': 'Contract Bride of Shadow City',
      'episodes': '85 Ep',
      'tag': 'Drama',
      'rating': '4.8',
      'views': '1.9M',
      'badge': null,
      'badgeColor': null,
      'gradient': [Color(0xFF2A1C30), Color(0xFF17101B)],
      'icon': Icons.favorite_rounded,
    },
    {
      'id': '6',
      'title': 'Martial God in Metropolis',
      'episodes': '100 Ep',
      'tag': 'Action',
      'rating': '4.9',
      'views': '3.2M',
      'badge': 'NEW',
      'badgeColor': AppColors.primary,
      'gradient': [Color(0xFF352012), Color(0xFF1A1009)],
      'icon': Icons.sports_martial_arts_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Search Input & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search 5,000+ short dramas, actors...',
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.neutral,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: AppColors.neutral,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.chipInactive,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          _categories[index],
                          style: AppTextStyles.chipText.copyWith(
                            color: isSelected ? Colors.white : AppColors.neutral,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Sub-header: Explore Dramas | 240 Titles, Trending filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Explore Dramas ',
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: '| 240 Titles',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Trending',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutralLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.neutralLight,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2-Column Grid of Dramas
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),
                itemCount: _dramas.length,
                itemBuilder: (context, index) {
                  final drama = _dramas[index];
                  return _buildGridCard(context, drama);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Map<String, dynamic> drama) {
    return GestureDetector(
      onTap: () => context.push('/drama/${drama['id']}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.8),
                gradient: LinearGradient(
                  colors: drama['gradient'] as List<Color>,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    // Icon
                    Center(
                      child: Icon(
                        drama['icon'] as IconData,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),

                    // Dark overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0x99000000),
                              Color(0xEB000000),
                            ],
                            stops: [0.4, 0.75, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Top Left Badge
                    if (drama['badge'] != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: drama['badgeColor'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            drama['badge'] as String,
                            style: AppTextStyles.badgeText.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),

                    // Top Right Episode badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          drama['episodes'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Rating
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.secondary, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            drama['rating'] as String,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' (${drama['views']})',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.neutral,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            drama['title'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.dramaTitle.copyWith(fontSize: 12.5),
          ),
          const SizedBox(height: 2),

          // Tag and Bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  drama['tag'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutral,
                    fontSize: 10,
                  ),
                ),
              ),
              const Icon(
                Icons.bookmark_outline_rounded,
                color: AppColors.neutral,
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
