import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/category_chips_bar.dart';
import '../widgets/continue_watching_section.dart';
import '../widgets/daily_coins_card.dart';
import '../widgets/featured_hero_banner.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/horizontal_drama_row.dart';
import '../widgets/top_ranked_section.dart';

/// Home Page - Main feed matching CineShorts design specification
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  static const List<Map<String, dynamic>> _billionaireSeries = [
    {
      'id': '201',
      'title': "Cold CEO's Secret Wife",
      'episodes': '88 Eps',
      'rating': '4.9',
      'views': '3.4M',
      'gradient': [Color(0xFF2B1C22), Color(0xFF130E14)],
      'icon': Icons.business_rounded,
    },
    {
      'id': '202',
      'title': "The Tycoon's Double Life",
      'episodes': '65 Eps',
      'rating': '4.8',
      'views': '2.1M',
      'gradient': [Color(0xFF162534), Color(0xFF0F1822)],
      'icon': Icons.diamond_rounded,
    },
    {
      'id': '203',
      'title': 'Forbidden Love with CEO',
      'episodes': '78 Eps',
      'rating': '4.9',
      'views': '4.8M',
      'gradient': [Color(0xFF261933), Color(0xFF15101E)],
      'icon': Icons.favorite_rounded,
    },
    {
      'id': '204',
      'title': 'The Secret Heir’s Payback',
      'episodes': '82 Eps',
      'rating': '4.7',
      'views': '1.9M',
      'gradient': [Color(0xFF332014), Color(0xFF1B1109)],
      'icon': Icons.military_tech_rounded,
    },
  ];

  static const List<Map<String, dynamic>> _werewolfSeries = [
    {
      'id': '301',
      'title': "Alpha King's Untamed Mate",
      'episodes': '90 Eps',
      'rating': '4.9',
      'views': '5.2M',
      'gradient': [Color(0xFF351221), Color(0xFF1C0A12)],
      'icon': Icons.nightlight_round,
    },
    {
      'id': '302',
      'title': "Shadow Wolf's Destiny",
      'episodes': '74 Eps',
      'rating': '4.8',
      'views': '3.1M',
      'gradient': [Color(0xFF1A1F36), Color(0xFF0F1222)],
      'icon': Icons.pets_rounded,
    },
    {
      'id': '303',
      'title': 'The Luna’s Second Chance',
      'episodes': '85 Eps',
      'rating': '4.9',
      'views': '2.8M',
      'gradient': [Color(0xFF2B1D38), Color(0xFF170F20)],
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceLight,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sticky / Top Bar
              const SliverToBoxAdapter(
                child: HomeTopBar(),
              ),

              // Category Pills Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                  child: CategoryChipsBar(
                    selectedIndex: _selectedCategoryIndex,
                    onCategorySelected: (index) {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  ),
                ),
              ),

              // Hero Featured Drama Banner
              const SliverToBoxAdapter(
                child: FeaturedHeroBanner(),
              ),

              // Continue Watching Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: ContinueWatchingSection(),
                ),
              ),

              // Top 10 Binge-Worthy Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: TopRankedSection(),
                ),
              ),

              // Claim Daily Free Coins CTA Card
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: DailyCoinsCard(),
                ),
              ),

              // Billionaire & CEO Series Section
              SliverToBoxAdapter(
                child: HorizontalDramaRow(
                  title: 'Billionaire & CEO Series',
                  icon: Icons.workspace_premium_rounded,
                  items: _billionaireSeries,
                ),
              ),

              // Werewolf & Romance Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: HorizontalDramaRow(
                    title: 'Werewolf & Fantasy Drama',
                    icon: Icons.auto_awesome_rounded,
                    items: _werewolfSeries,
                  ),
                ),
              ),

              // Bottom Spacing for BottomNavigationBar
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
