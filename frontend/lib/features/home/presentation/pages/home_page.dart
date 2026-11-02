import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import '../widgets/buddy_match_card.dart';
import '../widgets/departing_soon_section.dart';
import '../widgets/featured_tour_banner.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/horizontal_tour_row.dart';
import '../widgets/tour_type_chips_bar.dart';
import '../widgets/upcoming_trips_section.dart';

/// Trang chủ Phimium - toàn bộ dữ liệu lấy từ BE (GET /api/activity/getAll)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TourType? _selectedType;
  late Future<List<Tour>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<TourRepository>().getTours();
  }

  Future<void> _refresh() async {
    final future = getIt<TourRepository>().getTours(forceRefresh: true);
    setState(() => _future = future);
    await future.catchError((_) => <Tour>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: FutureBuilder<List<Tour>>(
            future: _future,
            builder: (context, snapshot) {
              final slivers = <Widget>[
                const SliverToBoxAdapter(child: HomeTopBar()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TourTypeChipsBar(
                      selected: _selectedType,
                      onChanged: (t) => setState(() => _selectedType = t),
                    ),
                  ),
                ),
              ];

              if (snapshot.connectionState != ConnectionState.done) {
                slivers.add(const SliverFillRemaining(child: LoadingWidget()));
              } else if (snapshot.hasError) {
                slivers.add(SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateWidget(
                    message: 'Không tải được danh sách tour.\nKiểm tra BE đang chạy và API_BASE_URL.',
                    onRetry: _refresh,
                  ),
                ));
              } else {
                slivers.addAll(_buildContent(snapshot.data ?? const []));
              }

              slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 32)));
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: slivers,
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(List<Tour> all) {
    final tours = _selectedType == null
        ? all
        : all.where((t) => t.type == _selectedType).toList();

    if (tours.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateWidget(
            message: 'Chưa có tour nào. Hãy thêm tour ở trang Admin của BE.',
            icon: Icons.travel_explore_rounded,
          ),
        ),
      ];
    }

    final food = tours.where((t) => t.type == TourType.food).toList();
    final history = tours.where((t) => t.type == TourType.history).toList();

    return [
      SliverToBoxAdapter(child: FeaturedTourBanner(tours: tours.take(5).toList())),
      SliverToBoxAdapter(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => state is AuthAuthenticated
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: UpcomingTripsSection(key: ValueKey(state.user.id)),
                )
              : const SizedBox.shrink(),
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: BuddyMatchCard(),
        ),
      ),
      SliverToBoxAdapter(
        child: HorizontalTourRow(
          title: AppStrings.foodTours,
          icon: Icons.ramen_dining_rounded,
          tours: food,
          onSeeAll: () => context.go('${AppRouter.explore}?type=food'),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: HorizontalTourRow(
            title: AppStrings.historyTours,
            icon: Icons.account_balance_rounded,
            tours: history,
            onSeeAll: () => context.go('${AppRouter.explore}?type=history'),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: DepartingSoonSection(tours: tours),
        ),
      ),
    ];
  }
}
