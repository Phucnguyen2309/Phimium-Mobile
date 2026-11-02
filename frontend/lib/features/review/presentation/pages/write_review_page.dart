import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../domain/repositories/review_repository.dart';

/// Viết đánh giá sau chuyến đi (POST /api/feedback/registrations/{id})
class WriteReviewPage extends StatefulWidget {
  final String bookingId;

  const WriteReviewPage({super.key, required this.bookingId});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  int _tourRating = 5;
  int _buddyRating = 5;
  final _tourComment = TextEditingController();
  final _buddyComment = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _tourComment.dispose();
    _buddyComment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await getIt<ReviewRepository>().createReview(
        bookingId: widget.bookingId,
        tourRating: _tourRating,
        tourComment: _tourComment.text.trim(),
        buddyRating: _buddyRating,
        buddyComment: _buddyComment.text.trim(),
      );
      if (!mounted) return;
      AppFeedback.success(
        context,
        'Cảm ơn bạn đã chia sẻ đánh giá sau chuyến đi!',
        title: 'Đã gửi đánh giá',
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, readableError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Đánh giá chuyến đi')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trải nghiệm chuyến đi', style: AppTextStyles.heading3),
                _StarPicker(
                  value: _tourRating,
                  onChanged: (v) => setState(() => _tourRating = v),
                ),
                TextField(
                  controller: _tourComment,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Chia sẻ cảm nhận về lịch trình, điểm đến...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đồng hành cùng Buddy', style: AppTextStyles.heading3),
                _StarPicker(
                  value: _buddyRating,
                  onChanged: (v) => setState(() => _buddyRating = v),
                ),
                TextField(
                  controller: _buddyComment,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Nhận xét về sự nhiệt tình, am hiểu của Buddy...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : const Text('Gửi đánh giá'),
          ),
        ],
      ),
    );
  }
}

class _StarPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StarPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(
          5,
          (i) => IconButton(
            onPressed: () => onChanged(i + 1),
            icon: Icon(
              i < value ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.ratingStar,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
