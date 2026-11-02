import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import 'review_page.dart';

/// Đánh giá tôi đã viết - GET /api/feedback/me
class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  late Future<List<Review>> _future = getIt<ReviewRepository>().getMyReviews();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myReviews)),
      body: AsyncView<List<Review>>(
        future: _future,
        onRetry: () => setState(() {
          _future = getIt<ReviewRepository>().getMyReviews();
        }),
        isEmpty: (list) => list.isEmpty,
        empty: const EmptyStateWidget(
          message: 'Bạn chưa viết đánh giá nào.',
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
