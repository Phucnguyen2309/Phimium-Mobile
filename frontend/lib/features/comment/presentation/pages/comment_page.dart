import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';

/// Comment Page - Comments & ratings for a drama
class CommentPage extends StatefulWidget {
  final String dramaId;

  const CommentPage({super.key, required this.dramaId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('${AppStrings.comments} (128)', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          // Comment list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.df),
              itemCount: 8,
              itemBuilder: (context, index) => _buildCommentItem(index),
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(AppDimens.df),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: AppStrings.addComment,
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  IconButton(
                    onPressed: () {
                      // TODO: Send comment
                      _commentController.clear();
                    },
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(int index) {
    final names = [
      'Minh Anh', 'Thùy Linh', 'Hoàng Nam', 'Thanh Hà',
      'Đức Trung', 'Mai Phương', 'Quang Huy', 'Ngọc Trâm',
    ];

    final comments = [
      'Phim hay quá! Tập nào cũng hấp dẫn 🔥',
      'Diễn viên chính diễn xuất sắc, rất tự nhiên.',
      'Ai biết khi nào ra tập mới không?',
      'Mình xem hết trong 1 ngày, nghiện luôn 😍',
      'Cốt truyện hơi giống phim A nhưng vẫn hay',
      'Phim free hết thì tốt quá',
      'Tập cuối twist không ngờ!',
      'Recommend cho mọi người nha, phim rất đáng xem.',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.df),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: HSLColor.fromAHSL(1.0, (index * 50.0) % 360, 0.5, 0.4).toColor(),
            child: Text(
              names[index][0],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      names[index],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${index + 1}h trước',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comments[index],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 8),
                // Action row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(Icons.favorite_outline, size: 16, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            '${(index + 1) * 3}',
                            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Trả lời',
                        style: TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w500),
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
