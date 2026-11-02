import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import '../../../tour/presentation/widgets/tour_card.dart';
import '../../data/datasources/wishlist_local_datasource.dart';

/// Tour yêu thích (thay cho Watchlist/Bookmark phim cũ)
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
      appBar: AppBar(title: const Text(AppStrings.wishlist)),
      body: ListenableBuilder(
        listenable: _wishlist,
        builder: (context, _) {
          if (_wishlist.ids.isEmpty) return _empty(context);
          return AsyncView<List<Tour>>(
            future: _future,
            onRetry: () => setState(() {
              _future = getIt<TourRepository>().getTours(forceRefresh: true);
            }),
            builder: (context, tours) {
              final saved = tours.where((t) => _wishlist.contains(t.id)).toList();
              if (saved.isEmpty) return _empty(context);
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: saved.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => TourListTile(tour: saved[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) => EmptyStateWidget(
        message: 'Bạn chưa lưu tour nào.\nBấm ♡ trên tour để lưu lại nhé!',
        icon: Icons.favorite_border_rounded,
        action: OutlinedButton(
          onPressed: () => context.go(AppRouter.explore),
          child: const Text(AppStrings.explore),
        ),
      );
}
