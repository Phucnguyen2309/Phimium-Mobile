import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../home/presentation/widgets/tour_type_chips_bar.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import '../../../tour/presentation/widgets/tour_card.dart';

/// Khám phá & tìm kiếm tour (thay cho màn Search phim cũ)
class ExplorePage extends StatefulWidget {
  /// 'food' | 'history' | null
  final String? initialType;

  const ExplorePage({super.key, this.initialType});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  late Future<List<Tour>> _future;
  TourType? _type;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _type = _typeFromParam(widget.initialType);
    _future = getIt<TourRepository>().getTours();
  }

  @override
  void didUpdateWidget(covariant ExplorePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialType != widget.initialType) {
      _type = _typeFromParam(widget.initialType);
    }
  }

  static TourType? _typeFromParam(String? value) => switch (value) {
        'food' => TourType.food,
        'history' => TourType.history,
        _ => null,
      };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tour> _filter(List<Tour> tours) {
    final q = _query.trim().toLowerCase();
    return tours.where((t) {
      if (_type != null && t.type != _type) return false;
      if (q.isEmpty) return true;
      final haystack = [
        t.title,
        t.locationName ?? '',
        t.address ?? '',
        ...t.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.explore)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm tour, địa điểm, món ăn...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          TourTypeChipsBar(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AsyncView<List<Tour>>(
              future: _future,
              onRetry: () => setState(() {
                _future = getIt<TourRepository>().getTours(forceRefresh: true);
              }),
              builder: (context, tours) {
                final results = _filter(tours);
                if (results.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'Không tìm thấy tour phù hợp.',
                    icon: Icons.search_off_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: results.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Text('${results.length} tour', style: AppTextStyles.caption);
                    }
                    return TourListTile(tour: results[i - 1]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
