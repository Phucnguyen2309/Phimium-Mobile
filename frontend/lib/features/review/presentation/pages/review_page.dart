import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

/// Đánh giá của một Buddy (thay cho màn Bình luận phim cũ)
class ReviewPage extends StatefulWidget {
  final String buddyId;
  final String? buddyName;

  const ReviewPage({super.key, required this.buddyId, this.buddyName});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Future<List<Review>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<ReviewRepository>().getBuddyReviews(widget.buddyId);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.buddyName;
    return Scaffold(
      appBar: AppBar(
        title: Text(name == null || name.isEmpty ? AppStrings.reviews : 'Đánh giá $name'),
      ),
      body: AsyncView<List<Review>>(
        future: _future,
        onRetry: () => setState(() {
          _future = getIt<ReviewRepository>().getBuddyReviews(widget.buddyId);
        }),
        isEmpty: (list) => list.isEmpty,
        empty: const EmptyStateWidget(
          message: 'Buddy này chưa có đánh giá nào.',
          icon: Icons.rate_review_outlined,
        ),
        builder: (context, reviews) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => ReviewTile(review: reviews[i]),
        ),
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  final Review review;

  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryMuted,
                child: Text(
                  (review.reviewerName ?? '').isEmpty
                      ? '?'
                      : review.reviewerName!.characters.first.toUpperCase(),
                  style: AppTextStyles.labelBold.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(review.reviewerName ?? 'Khách', style: AppTextStyles.labelBold),
              ),
              Text(Formatters.date(review.createdAt), style: AppTextStyles.caption),
            ],
          ),
          if (review.tourTitle != null) ...[
            const SizedBox(height: 6),
            Text(review.tourTitle!, style: AppTextStyles.caption),
          ],
          if (review.tripRating != null) ...[
            const SizedBox(height: 8),
            _RatingLine(label: 'Chuyến đi', rating: review.tripRating!),
          ],
          if ((review.tripComment ?? '').isNotEmpty)
            Text(review.tripComment!, style: AppTextStyles.bodyMedium),
          if (review.buddyRating != null) ...[
            const SizedBox(height: 8),
            _RatingLine(label: 'Buddy', rating: review.buddyRating!),
          ],
          if ((review.buddyComment ?? '').isNotEmpty)
            Text(review.buddyComment!, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _RatingLine extends StatelessWidget {
  final String label;
  final int rating;

  const _RatingLine({required this.label, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: AppTextStyles.caption),
        ...List.generate(
          5,
          (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 16,
            color: AppColors.ratingStar,
          ),
        ),
      ],
    );
  }
}
