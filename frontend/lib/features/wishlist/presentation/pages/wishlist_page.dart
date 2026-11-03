import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import '../../../tour/presentation/widgets/tour_card.dart';
import '../../data/datasources/wishlist_local_datasource.dart';

/// Tour yêu thích - đồng bộ bảng màu Royal Navy & Golden Amber
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _wishlist = getIt<WishlistLocalDataSource>();
  late Future<List<Tour>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<TourRepository>().getTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _wishlist,
          builder: (context, _) {
            final count = _wishlist.ids.length;
            return Column(
              children: [
                _WishlistHeader(count: count),
                Expanded(
                  child: count == 0
                      ? _buildEmptyState(context)
                      : AsyncView<List<Tour>>(
                          future: _future,
                          onRetry: () => setState(() {
                            _future = getIt<TourRepository>().getTours(
                              forceRefresh: true,
                            );
                          }),
                          builder: (context, tours) {
                            final saved = tours
                                .where((t) => _wishlist.contains(t.id))
                                .toList();
                            if (saved.isEmpty) return _buildEmptyState(context);
                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                              itemCount: saved.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) =>
                                  TourListTile(tour: saved[i]),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFECDD3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE11D48),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Chưa có tour yêu thích nào',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy thả tim ♡ vào những hành trình ẩm thực hoặc di sản bạn ấn tượng để dễ dàng xem lại và đặt lịch bất cứ lúc nào!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(210, 46),
                ),
                onPressed: () => context.go(AppRouter.explore),
                icon: const Icon(
                  Icons.explore_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
                label: const Text('Khám phá tour ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishlistHeader extends StatelessWidget {
  final int count;

  const _WishlistHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BỘ SƯU TẬP CỦA BẠN',
                  style: AppTextStyles.badgeText.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 0.8,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.wishlist,
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count > 0
                      ? 'Bạn đang lưu $count hành trình khám phá Sài Gòn'
                      : 'Lưu lại những tour bạn muốn trải nghiệm',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
