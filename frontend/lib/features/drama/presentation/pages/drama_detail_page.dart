import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';

/// Drama Detail Page - Shows drama info, episodes, and comments
class DramaDetailPage extends StatefulWidget {
  final String dramaId;

  const DramaDetailPage({super.key, required this.dramaId});

  @override
  State<DramaDetailPage> createState() => _DramaDetailPageState();
}

class _DramaDetailPageState extends State<DramaDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Drama banner with back button
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, size: 18, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner placeholder
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.movie_creation_outlined,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xFF0A0A0F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drama info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.df),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Bí Mật Tình Yêu',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  // Meta info row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 4),
                      const Text('4.8', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: AppDimens.df),
                      const Icon(Icons.visibility_outlined, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text('1.2M', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: AppDimens.df),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Đang chiếu',
                          style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.md),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Tình cảm', 'Lãng mạn', 'Drama', 'Hàn Quốc']
                        .map((tag) => Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(color: AppColors.border),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppDimens.df),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(AppStrings.watchNow),
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() => _isBookmarked = !_isBookmarked);
                          },
                          icon: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                            color: _isBookmarked ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  // Description
                  Text(
                    'Câu chuyện tình yêu đầy lãng mạn giữa hai trái tim vô tình gặp nhau trong một đêm mưa. Từ đó, họ cùng nhau trải qua bao thăng trầm cuộc sống và dần khám phá những bí mật mà mỗi người giấu kín...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: AppStrings.episodes),
                  Tab(text: AppStrings.comments),
                  Tab(text: 'Tương tự'),
                ],
              ),
            ),
          ),

          // Tab content - Episodes list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildEpisodeTile(index),
              childCount: 12,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeTile(int index) {
    final bool isLocked = index > 2;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.df,
        vertical: AppDimens.xs,
      ),
      leading: Container(
        width: 100,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
          gradient: LinearGradient(
            colors: [
              HSLColor.fromAHSL(1.0, (index * 30.0) % 360, 0.4, 0.25).toColor(),
              HSLColor.fromAHSL(1.0, ((index * 30.0) + 20) % 360, 0.3, 0.2).toColor(),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                isLocked ? Icons.lock_outline : Icons.play_circle_outline,
                color: Colors.white.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Text(
                '${(index + 1) * 3}:${(index * 17 % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        'Tập ${index + 1}: ${index == 0 ? "Cuộc gặp gỡ" : "Khám phá bí mật ${index + 1}"}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Row(
        children: [
          Text(
            '${(index + 1) * 3} phút',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (isLocked) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on_outlined, size: 12, color: AppColors.secondary),
                  const SizedBox(width: 2),
                  Text(
                    '${(index + 1) * 5}',
                    style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: () {
        // TODO: Navigate to video player or prompt unlock
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
