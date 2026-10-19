import '../entities/drama.dart';

/// Drama repository interface - Domain layer
abstract class DramaRepository {
  Future<List<Drama>> getTrending({int page = 1, int limit = 10});
  Future<List<Drama>> getByCategory(String categoryId, {int page = 1});
  Future<List<Drama>> getNewReleases({int page = 1, int limit = 10});
  Future<Drama> getDetail(String dramaId);
  Future<List<Episode>> getEpisodes(String dramaId);
  Future<Episode> getEpisodeDetail(String dramaId, String episodeId);
  Future<List<Category>> getCategories();
  Future<List<Drama>> getRecommended({int limit = 10});
}
