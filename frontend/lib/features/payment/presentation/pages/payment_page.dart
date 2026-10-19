import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';

/// Payment Page - Buy coins/credits
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedPackage = 1;

  final List<_CoinPackage> _packages = [
    _CoinPackage(id: 0, coins: 50, price: 19000, label: 'Gói nhỏ', icon: '🪙'),
    _CoinPackage(id: 1, coins: 200, price: 69000, label: 'Phổ biến', icon: '💰', isPopular: true),
    _CoinPackage(id: 2, coins: 500, price: 149000, label: 'Tiết kiệm', icon: '💎', discount: 15),
    _CoinPackage(id: 3, coins: 1000, price: 269000, label: 'VIP', icon: '👑', discount: 25),
  ];

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
        title: Text(AppStrings.buyCoins, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.df),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current balance
            _buildBalanceCard(),
            const SizedBox(height: AppDimens.xl),

            Text('Chọn gói xu', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDimens.df),

            // Coin packages
            ..._packages.map((pkg) => _buildPackageCard(pkg)),

            const SizedBox(height: AppDimens.xl),

            // Purchase button
            ElevatedButton(
              onPressed: () {
                // TODO: Process payment
              },
              child: Text('Mua ${_packages[_selectedPackage].coins} xu - ${_formatPrice(_packages[_selectedPackage].price)}đ'),
            ),

            const SizedBox(height: AppDimens.df),

            // Note
            Text(
              '* Xu không có thời hạn sử dụng. Sau khi mua, xu sẽ được cộng vào tài khoản ngay lập tức.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
            ),

            const SizedBox(height: AppDimens.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF11001C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppDimens.df),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số dư hiện tại',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '1,250 xu',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(_CoinPackage package) {
    final isSelected = _selectedPackage == package.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        padding: const EdgeInsets.all(AppDimens.df),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Text(package.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${package.coins} xu',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        package.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatPrice(package.price)}đ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                    ),
                    if (package.discount != null)
                      Text(
                        'Giảm ${package.discount}%',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppDimens.sm),
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            // Popular badge
            if (package.isPopular)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'HOT',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _CoinPackage {
  final int id;
  final int coins;
  final int price;
  final String label;
  final String icon;
  final bool isPopular;
  final int? discount;

  _CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    required this.label,
    required this.icon,
    this.isPopular = false,
    this.discount,
  });
}
