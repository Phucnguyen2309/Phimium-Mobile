import 'package:equatable/equatable.dart';

/// Đánh giá chuyến đi & Buddy (FeedBackResponse của BE)
class Review extends Equatable {
  final String id;
  final String? reviewerName;
  final String? buddyName;
  final String? tourTitle;
  final int? tripRating;
  final String? tripComment;
  final int? buddyRating;
  final String? buddyComment;
  final DateTime? createdAt;

  const Review({
    required this.id,
    this.reviewerName,
    this.buddyName,
    this.tourTitle,
    this.tripRating,
    this.tripComment,
    this.buddyRating,
    this.buddyComment,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}
