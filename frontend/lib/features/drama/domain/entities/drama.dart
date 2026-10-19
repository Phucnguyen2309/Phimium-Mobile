import 'package:equatable/equatable.dart';

/// Drama entity - Domain layer
class Drama extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String? bannerUrl;
  final String? genre;
  final List<String> tags;
  final double rating;
  final int totalEpisodes;
  final int viewCount;
  final int likeCount;
  final bool isFree;
  final int? coinPrice;
  final String status; // ongoing, completed
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Drama({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    this.bannerUrl,
    this.genre,
    this.tags = const [],
    this.rating = 0.0,
    this.totalEpisodes = 0,
    this.viewCount = 0,
    this.likeCount = 0,
    this.isFree = false,
    this.coinPrice,
    this.status = 'ongoing',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, thumbnailUrl];
}

/// Episode entity
class Episode extends Equatable {
  final String id;
  final String dramaId;
  final int episodeNumber;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final Duration duration;
  final bool isFree;
  final int? coinPrice;
  final int viewCount;

  const Episode({
    required this.id,
    required this.dramaId,
    required this.episodeNumber,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    this.isFree = true,
    this.coinPrice,
    this.viewCount = 0,
  });

  @override
  List<Object?> get props => [id, dramaId, episodeNumber];
}

/// Category entity
class Category extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;

  const Category({
    required this.id,
    required this.name,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name];
}
