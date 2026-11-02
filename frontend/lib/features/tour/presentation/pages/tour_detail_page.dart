import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_image.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/tour.dart';
import '../../domain/repositories/tour_repository.dart';
import '../widgets/itinerary_timeline.dart';
import '../widgets/tour_card.dart';

/// Chi tiết tour - dữ liệu từ GET /api/activity/{id}
class TourDetailPage extends StatefulWidget {
  final String tourId;

  const TourDetailPage({super.key, required this.tourId});

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  late Future<TourDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = getIt<TourRepository>().getTourDetail(widget.tourId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView<TourDetail>(
        future: _future,
        onRetry: () => setState(_load),
        builder: (context, detail) => _DetailBody(detail: detail),
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  final TourDetail detail;

  const _DetailBody({required this.detail});

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  final PageController _pageController = PageController();
  int _currentImage = 0;

  TourDetail get detail => widget.detail;
  Tour get tour => detail.tour;

  /// Danh sách ảnh hiển thị trong trang chi tiết:
  /// Ưu tiên danh sách `imageUrls` của tour (nhiều ảnh), nếu rỗng thì dùng `thumbnailUrl`.
  List<String> get _galleryImages {
    final cleaned = detail.imageUrls
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isNotEmpty) return cleaned;
    final thumb = tour.thumbnailUrl?.trim();
    if (thumb != null && thumb.isNotEmpty) return [thumb];
    return const [];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToImage(int index, int total) {
    if (index < 0 || index >= total) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _openLightbox(BuildContext context, List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => _PhotoLightboxDialog(
        images: images,
        initialIndex: initialIndex,
        title: tour.title,
      ),
    );
  }

  void _showGuidelines(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _GuidelinesDialog(tourId: tour.id, tourTitle: tour.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departures = tour.upcomingDepartures;
    final images = _galleryImages;
    final safeIndex = images.isEmpty ? 0 : _currentImage.clamp(0, images.length - 1);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: Padding(
                padding: const EdgeInsets.all(6),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.92),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: WishlistButton(tourId: tour.id, size: 38),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: images.isEmpty
                    ? AppCachedImage(
                        imageUrl: null,
                        width: double.infinity,
                        height: 320,
                        placeholderIcon: tour.type.icon,
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (idx) => setState(() => _currentImage = idx),
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () => _openLightbox(context, images, index),
                              child: AppCachedImage(
                                imageUrl: images[index],
                                width: double.infinity,
                                height: 320,
                                placeholderIcon: tour.type.icon,
                              ),
                            ),
                          ),
                          // Nút chuyển ảnh trái/phải khi có nhiều ảnh
                          if (images.length > 1) ...[
                            if (safeIndex > 0)
                              Positioned(
                                left: 10,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: _GalleryNavButton(
                                    icon: Icons.chevron_left_rounded,
                                    onTap: () => _goToImage(safeIndex - 1, images.length),
                                  ),
                                ),
                              ),
                            if (safeIndex < images.length - 1)
                              Positioned(
                                right: 10,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: _GalleryNavButton(
                                    icon: Icons.chevron_right_rounded,
                                    onTap: () => _goToImage(safeIndex + 1, images.length),
                                  ),
                                ),
                              ),
                          ],
                          // Nhãn số lượng ảnh + nút xem toàn màn hình
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: GestureDetector(
                              onTap: () => _openLightbox(context, images, safeIndex),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.82),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.photo_library_outlined,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${safeIndex + 1}/${images.length} ảnh',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dãy thumbnail nhỏ khi tour có nhiều hơn 1 ảnh
                    if (images.length > 1) ...[
                      SizedBox(
                        height: 62,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final selected = index == safeIndex;
                            return GestureDetector(
                              onTap: () => _goToImage(index, images.length),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 82,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: selected ? 2.5 : 1,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.18),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9.5),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      AppCachedImage(
                                        imageUrl: images[index],
                                        width: 82,
                                        height: 62,
                                        placeholderIcon: tour.type.icon,
                                      ),
                                      if (!selected)
                                        Container(
                                          color: Colors.black
                                              .withValues(alpha: 0.18),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Row(
                      children: [
                        TourTypeBadge(type: tour.type),
                        const Spacer(),
                        if (detail.averageRating > 0) ...[
                          const Icon(Icons.star_rounded, color: AppColors.ratingStar, size: 18),
                          const SizedBox(width: 2),
                          Text('${detail.averageRating}/5', style: AppTextStyles.labelBold),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(tour.title, style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      text: [tour.locationName, tour.address]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(' • '),
                    ),
                    if (tour.totalDurationMinutes > 0)
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        text: 'Khoảng ${Formatters.duration(tour.totalDurationMinutes)}',
                      ),
                    if (tour.maxParticipants != null)
                      _InfoRow(
                        icon: Icons.groups_2_outlined,
                        text: 'Tối đa ${tour.maxParticipants} khách',
                      ),
                    if (tour.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tour.tags
                            .map((t) => Chip(
                                  label: Text(t),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                    if (detail.hostBuddyName != null) ...[
                      const SizedBox(height: AppDimens.lg),
                      _BuddyCard(detail: detail),
                    ],
                    if ((tour.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppDimens.lg),
                      Text(AppStrings.description, style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(tour.description!, style: AppTextStyles.bodyMedium),
                    ],
                    if (tour.itineraryStops.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.lg),
                      Row(
                        children: [
                          Text(AppStrings.itinerary, style: AppTextStyles.heading3),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/tour/${tour.id}/itinerary'),
                            child: const Text(AppStrings.seeAll),
                          ),
                        ],
                      ),
                      ItineraryTimeline(stops: tour.itineraryStops.take(3).toList()),
                    ],
                    const SizedBox(height: AppDimens.lg),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        onTap: () => _showGuidelines(context),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.health_and_safety_outlined,
                              color: AppColors.primary),
                        ),
                        title: Text(AppStrings.guidelines, style: AppTextStyles.labelBold),
                        subtitle: Text('Xem lưu ý và quy định an toàn trước chuyến đi',
                            style: AppTextStyles.caption),
                        trailing:
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                      ),
                    ),
                    const SizedBox(height: AppDimens.lg),
                    Text(AppStrings.departures, style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    if (departures.isEmpty)
                      Text(AppStrings.noDepartures, style: AppTextStyles.bodyMedium)
                    else
                      ...departures.take(4).map((d) => _DepartureTile(departure: d)),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BookingBar(tour: tour, enabled: departures.isNotEmpty),
        ),
      ],
    );
  }
}

class _GalleryNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GalleryNavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _PhotoLightboxDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;

  const _PhotoLightboxDialog({
    required this.images,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<_PhotoLightboxDialog> createState() => _PhotoLightboxDialogState();
}

class _PhotoLightboxDialogState extends State<_PhotoLightboxDialog> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.images.length) return;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black.withValues(alpha: 0.94),
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, idx) => InteractiveViewer(
                minScale: 1,
                maxScale: 3.5,
                child: Center(
                  child: AppCachedImage(
                    imageUrl: widget.images[idx],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.title} (${_index + 1}/${widget.images.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelBold.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            if (widget.images.length > 1 && _index > 0)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _GalleryNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _step(-1),
                  ),
                ),
              ),
            if (widget.images.length > 1 && _index < widget.images.length - 1)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _GalleryNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _step(1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuidelinesDialog extends StatefulWidget {
  final String tourId;
  final String tourTitle;

  const _GuidelinesDialog({
    required this.tourId,
    required this.tourTitle,
  });

  @override
  State<_GuidelinesDialog> createState() => _GuidelinesDialogState();
}

class _GuidelinesDialogState extends State<_GuidelinesDialog> {
  late Future<TourGuideline?> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<TourRepository>().getTourGuidelines(widget.tourId);
  }

  /// Tách danh sách quy tắc an toàn từ chuỗi nhiều dòng của BE (GuidelineConstants)
  List<String> _parseSafetyRules(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^\s*\d+[\.\)]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.84;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header màu Navy đồng bộ với Web
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.guidelines,
                          style: AppTextStyles.labelBold.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.tourTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FutureBuilder<TourGuideline?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final g = snapshot.data;
                  if (g == null) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Tour hiện chưa có cẩm nang hướng dẫn riêng.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }
                  final rules = _parseSafetyRules(g.safetyRules);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mục 1: Hướng dẫn tập trung
                        if ((g.content ?? '').isNotEmpty) ...[
                          Text(
                            'HƯỚNG DẪN TẬP TRUNG',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFFB45309),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    g.content!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: const Color(0xFF78350F),
                                      fontWeight: FontWeight.w600,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        // Mục 2: Quy tắc an toàn chung (danh sách đánh số 1..5 từ BE)
                        if (rules.isNotEmpty) ...[
                          Text(
                            'QUY TẮC AN TOÀN CHUNG',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(rules.length, (idx) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${idx + 1}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        rules[idx],
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textPrimary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Tôi đã đọc và hiểu rõ quy tắc'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _BuddyCard extends StatelessWidget {
  final TourDetail detail;

  const _BuddyCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipOval(
            child: AppCachedImage(
              imageUrl: detail.hostAvatarUrl,
              width: 48,
              height: 48,
              placeholderIcon: Icons.person_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.yourBuddy, style: AppTextStyles.caption),
                Text(detail.hostBuddyName!, style: AppTextStyles.labelBold),
                if ((detail.hostIntroduction ?? '').isNotEmpty)
                  Text(
                    detail.hostIntroduction!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          if (detail.hostBuddyId != null)
            TextButton(
              onPressed: () => context.push(
                '/buddy/${detail.hostBuddyId}/reviews'
                '?name=${Uri.encodeComponent(detail.hostBuddyName ?? '')}',
              ),
              child: const Text(AppStrings.reviews),
            ),
        ],
      ),
    );
  }
}

class _DepartureTile extends StatelessWidget {
  final TourDeparture departure;

  const _DepartureTile({required this.departure});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(Formatters.date(departure.date), style: AppTextStyles.labelBold),
          const SizedBox(width: 8),
          Text(
            '${Formatters.time(departure.startTime)} - ${Formatters.time(departure.endTime)}',
            style: AppTextStyles.bodyMedium,
          ),
          const Spacer(),
          if (departure.capacity != null)
            Text('${departure.capacity} chỗ', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  final Tour tour;
  final bool enabled;

  const _BookingBar({required this.tour, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giá từ', style: AppTextStyles.caption),
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: Formatters.vnd(tour.price),
                  style: AppTextStyles.price.copyWith(fontSize: 18),
                ),
                TextSpan(text: AppStrings.perPerson, style: AppTextStyles.caption),
              ])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: enabled ? () => context.push('/tour/${tour.id}/book') : null,
              child: const Text(AppStrings.bookNow),
            ),
          ),
        ],
      ),
    );
  }
}
