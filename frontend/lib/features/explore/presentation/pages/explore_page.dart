import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../home/presentation/widgets/tour_type_chips_bar.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import '../../../tour/presentation/widgets/tour_card.dart';

/// Khám phá & tìm kiếm tour - đồng bộ bảng màu Royal Navy & Golden Amber
class ExplorePage extends StatefulWidget {
  /// 'food' | 'history' | null
  final String? initialType;

  const ExplorePage({super.key, this.initialType});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  late Future<List<Tour>> _future;
  TourType? _type;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _type = _typeFromParam(widget.initialType);
    _future = getIt<TourRepository>().getTours();
  }

  @override
  void didUpdateWidget(covariant ExplorePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialType != widget.initialType) {
      _type = _typeFromParam(widget.initialType);
    }
  }

  static TourType? _typeFromParam(String? value) => switch (value) {
        'food' => TourType.food,
        'history' => TourType.history,
        _ => null,
      };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tour> _filter(List<Tour> tours) {
    final q = _query.trim().toLowerCase();
    return tours.where((t) {
      if (_type != null && t.type != _type) return false;
      if (q.isEmpty) return true;
      final haystack = [
        t.title,
        t.locationName ?? '',
        t.address ?? '',
        ...t.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Navy nổi bật kèm thanh tìm kiếm
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KHÁM PHÁ HÀNH TRÌNH',
                              style: AppTextStyles.badgeText.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 0.8,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Tìm kiếm tour bản địa',
                              style: AppTextStyles.heading3.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tìm tour, địa điểm, món ăn...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TourTypeChipsBar(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AsyncView<List<Tour>>(
                future: _future,
                onRetry: () => setState(() {
                  _future =
                      getIt<TourRepository>().getTours(forceRefresh: true);
                }),
                builder: (context, tours) {
                  final results = _filter(tours);
                  if (results.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'Không tìm thấy tour phù hợp.',
                      icon: Icons.search_off_rounded,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: results.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Tìm thấy ${results.length} hành trình phù hợp',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return TourListTile(tour: results[i - 1]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
