import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../review/domain/entities/review.dart';
import '../../../review/domain/repositories/review_repository.dart';
import '../../domain/entities/buddy_schedule.dart';
import '../../domain/repositories/buddy_repository.dart';

/// Cổng Điều Hành Buddy trên Mobile:
/// - Dùng BottomNavigationBar ở dưới (Lịch dẫn tour / Đánh giá / Tài khoản)
/// - Không dùng Drawer bên trái và không dùng thanh chuyển tab ở giữa trang
class BuddyWorkspacePage extends StatefulWidget {
  const BuddyWorkspacePage({super.key});

  @override
  State<BuddyWorkspacePage> createState() => _BuddyWorkspacePageState();
}

class _BuddyWorkspacePageState extends State<BuddyWorkspacePage> {
  int _selectedIndex = 0; // 0: Lịch dẫn tour, 1: Đánh giá, 2: Tài khoản
  String _scheduleFilter = 'ALL'; // 'ALL' | 'UPCOMING' | 'IN_PROGRESS' | 'COMPLETED'
  bool _isAvailable = true;
  bool _statusLoading = false;
  bool _loading = true;
  String? _error;

  List<BuddySchedule> _schedules = const [];
  List<Review> _feedbacks = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authState = context.read<AuthBloc>().state;
      final buddyId = authState is AuthAuthenticated ? authState.user.buddyId : null;

      final schedules = await getIt<BuddyRepository>().getMySchedules();
      List<Review> feedbacks = const [];
      if (buddyId != null && buddyId.isNotEmpty) {
        try {
          feedbacks = await getIt<ReviewRepository>().getBuddyReviews(buddyId);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _schedules = schedules;
        _feedbacks = feedbacks;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = readableError(e);
      if (msg.toLowerCase().contains('invalid token') ||
          msg.toLowerCase().contains('unauthorized')) {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        AppFeedback.info(
          context,
          'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          title: 'Hết phiên làm việc',
        );
        context.go(AppRouter.login);
        return;
      }
      setState(() {
        _error = msg;
        _loading = false;
      });
    }
  }

  Future<void> _toggleStatus() async {
    setState(() => _statusLoading = true);
    try {
      final nextStatus = _isAvailable ? 'INACTIVE' : 'ACTIVE';
      await getIt<BuddyRepository>().updateMyStatus(nextStatus);
      if (!mounted) return;
      setState(() => _isAvailable = !_isAvailable);
      AppFeedback.success(
        context,
        _isAvailable
            ? 'Đã bật trạng thái: Sẵn sàng nhận tour'
            : 'Đã chuyển sang trạng thái: Tạm nghỉ',
        title: 'Đã cập nhật trạng thái',
      );
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, readableError(e));
    } finally {
      if (mounted) setState(() => _statusLoading = false);
    }
  }

  Future<void> _confirmLogout() async {
    final ok = await AppFeedback.confirm(
      context,
      title: 'Xác nhận đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Buddy?',
      confirmLabel: 'Đăng xuất',
      cancelLabel: 'Hủy',
      isDanger: true,
      icon: Icons.logout_rounded,
    );
    if (!ok || !mounted) return;
    context.read<AuthBloc>().add(AuthLogoutRequested());
    context.go(AppRouter.login);
  }

  void _openMembersModal(BuddySchedule schedule) {
    showDialog<void>(
      context: context,
      builder: (_) => _TourMembersDialog(
        schedule: schedule,
        onChanged: _loadDashboard,
      ),
    );
  }

  int get _upcomingCount =>
      _schedules.where((s) => s.status == 'UPCOMING').length;

  int get _inProgressCount =>
      _schedules.where((s) => s.status == 'IN_PROGRESS').length;

  int get _totalGuests =>
      _schedules.fold(0, (sum, s) => sum + s.totalGuests);

  String get _avgRating {
    if (_feedbacks.isEmpty) return '5.0';
    final ratings = _feedbacks
        .map((f) => f.buddyRating ?? f.tripRating ?? 5)
        .toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    return avg.toStringAsFixed(1);
  }

  List<BuddySchedule> get _filteredSchedules {
    if (_scheduleFilter == 'ALL') return _schedules;
    return _schedules.where((s) => s.status == _scheduleFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final User? user = authState is AuthAuthenticated ? authState.user : null;
    final pageTitle = switch (_selectedIndex) {
      0 => 'Lịch dẫn tour',
      1 => 'Đánh giá từ khách',
      _ => 'Tài khoản Buddy',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── HEADER NAVY ĐỒNG BỘ PHIMIUM BUDDY PORTAL ──
            _BuddyTopHeader(
              title: pageTitle,
              userName: user?.fullName,
              isAvailable: _isAvailable,
              statusLoading: _statusLoading,
              loading: _loading,
              onToggleStatus: _toggleStatus,
              onRefresh: _loadDashboard,
            ),
            Expanded(
              child: _selectedIndex == 2
                  ? _buildProfileTab(user)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadDashboard,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                        children: [
                          // ── 1. METRICS STRIP NỔI BẬT ──
                          _MetricsStrip(
                            upcomingCount: _upcomingCount,
                            inProgressCount: _inProgressCount,
                            totalGuests: _totalGuests,
                            avgRating: _avgRating,
                            reviewCount: _feedbacks.length,
                          ),
                          const SizedBox(height: 12),

                          // ── 2. MAIN CONTENT CARD ──
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusLg),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.borderLight),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _selectedIndex == 0
                                                  ? Icons.event_note_rounded
                                                  : Icons.reviews_rounded,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _selectedIndex == 0
                                                      ? 'Danh sách ca tour được giao'
                                                      : 'Đánh giá & Nhận xét từ khách',
                                                  style: AppTextStyles.labelBold
                                                      .copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                Text(
                                                  _selectedIndex == 0
                                                      ? 'Hiển thị ${_filteredSchedules.length} ca tour theo bộ lọc hiện tại'
                                                      : 'Tổng cộng ${_feedbacks.length} lượt nhận xét sau chuyến đi',
                                                  style: AppTextStyles.caption,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_selectedIndex == 0) ...[
                                        const SizedBox(height: 12),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              ('ALL', 'Tất cả'),
                                              ('UPCOMING', 'Sắp tới'),
                                              ('IN_PROGRESS', 'Đang diễn ra'),
                                              ('COMPLETED', 'Đã hoàn thành'),
                                            ].map((f) {
                                              final selected =
                                                  _scheduleFilter == f.$1;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 6),
                                                child: GestureDetector(
                                                  onTap: () => setState(() =>
                                                      _scheduleFilter = f.$1),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 180),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: selected
                                                          ? AppColors.primary
                                                          : AppColors
                                                              .background,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                        color: selected
                                                            ? AppColors.primary
                                                            : AppColors.border,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      f.$2,
                                                      style: AppTextStyles
                                                          .chipText
                                                          .copyWith(
                                                        color: selected
                                                            ? Colors.white
                                                            : AppColors
                                                                .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: _loading
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 32),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        )
                                      : _error != null
                                          ? Column(
                                              children: [
                                                Text(_error!,
                                                    style: AppTextStyles
                                                        .bodyMedium),
                                                const SizedBox(height: 8),
                                                TextButton(
                                                  onPressed: _loadDashboard,
                                                  child: const Text(
                                                      'Nhấn để tải lại'),
                                                ),
                                              ],
                                            )
                                          : _selectedIndex == 0
                                              ? _buildSchedulesContent()
                                              : _buildReviewsContent(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bottomNav,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.neutral,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'Lịch dẫn tour',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_outline_rounded),
                activeIcon: Icon(Icons.star_rounded),
                label: 'Đánh giá',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(User? user) {
    final initial = (user?.fullName ?? '').isEmpty
        ? 'B'
        : user!.fullName.characters.first.toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Buddy',
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'BUDDY HƯỚNG DẪN VIÊN',
                        style: AppTextStyles.badgeText.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: SwitchListTile(
            value: _isAvailable,
            activeColor: AppColors.success,
            onChanged: _statusLoading ? null : (_) => _toggleStatus(),
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (_isAvailable ? AppColors.success : AppColors.neutral)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isAvailable
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                color: _isAvailable ? AppColors.success : AppColors.neutral,
                size: 22,
              ),
            ),
            title: Text('Trạng thái nhận lịch dẫn tour',
                style: AppTextStyles.labelBold),
            subtitle: Text(
              _isAvailable
                  ? 'Đang bật: Sẵn sàng nhận ca tour mới'
                  : 'Đang tắt: Tạm nghỉ nhận ca',
              style: AppTextStyles.caption,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            onTap: _confirmLogout,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
            ),
            title: Text(
              'Đăng xuất',
              style: AppTextStyles.labelBold.copyWith(color: AppColors.error),
            ),
            subtitle: Text('Thoát khỏi tài khoản Buddy',
                style: AppTextStyles.caption),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulesContent() {
    final list = _filteredSchedules;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            const Icon(Icons.event_note_outlined,
                size: 38, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text(
              'Không có ca tour nào trong mục này',
              style: AppTextStyles.labelBold,
            ),
            const SizedBox(height: 4),
            Text(
              'Khi quản trị viên phân công ca tour mới, lịch trình và sĩ số đoàn khách sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return Column(
      children: list
          .map((dep) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ScheduleItemCard(
                  schedule: dep,
                  onOpenRoster: () => _openMembersModal(dep),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildReviewsContent() {
    if (_feedbacks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            const Icon(Icons.star_border_rounded,
                size: 38, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text(
              'Chưa có phản hồi nào từ khách hàng',
              style: AppTextStyles.labelBold,
            ),
            const SizedBox(height: 4),
            Text(
              'Đánh giá và ý kiến đóng góp từ người tham gia sẽ được tổng hợp tại đây sau mỗi chuyến đi.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _feedbacks.map((fb) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fb.reviewerName ?? 'Khách trải nghiệm',
                          style: AppTextStyles.labelBold,
                        ),
                        if ((fb.tourTitle ?? '').isNotEmpty)
                          Text('Tour: ${fb.tourTitle}',
                              style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  if (fb.createdAt != null)
                    Text(Formatters.date(fb.createdAt),
                        style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Chất lượng tour', style: AppTextStyles.caption),
                        const Spacer(),
                        _StarRow(rating: fb.tripRating ?? 5),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (fb.tripComment ?? '').isNotEmpty
                          ? '"${fb.tripComment}"'
                          : 'Không có nhận xét chi tiết.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Thái độ phục vụ của Buddy',
                            style: AppTextStyles.caption),
                        const Spacer(),
                        _StarRow(rating: fb.buddyRating ?? 5),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (fb.buddyComment ?? '').isNotEmpty
                          ? '"${fb.buddyComment}"'
                          : 'Không có nhận xét chi tiết.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Header Navy trên cùng của Buddy Portal
class _BuddyTopHeader extends StatelessWidget {
  final String title;
  final String? userName;
  final bool isAvailable;
  final bool statusLoading;
  final bool loading;
  final VoidCallback onToggleStatus;
  final VoidCallback onRefresh;

  const _BuddyTopHeader({
    required this.title,
    required this.userName,
    required this.isAvailable,
    required this.statusLoading,
    required this.loading,
    required this.onToggleStatus,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hàng 1: Logo + Tên đầy đủ của Buddy + Nút Làm mới
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 34,
                    height: 34,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'BUDDY',
                          style: AppTextStyles.badgeText.copyWith(
                            color: AppColors.secondary,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      userName == null || userName!.isEmpty
                          ? 'Buddy Phimium'
                          : userName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelBold.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Làm mới',
                visualDensity: VisualDensity.compact,
                onPressed: loading ? null : onRefresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 10),
          // Hàng 2: Tiêu đề trang hiện tại + Cụm trạng thái Sẵn sàng / Tạm nghỉ
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(9, 4, 4, 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAvailable
                            ? const Color(0xFF34D399)
                            : AppColors.neutralLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAvailable ? 'Sẵn sàng' : 'Tạm nghỉ',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(width: 7),
                    InkWell(
                      borderRadius: BorderRadius.circular(7),
                      onTap: statusLoading ? null : onToggleStatus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color:
                              isAvailable ? Colors.white : AppColors.secondary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          statusLoading
                              ? '...'
                              : (isAvailable ? 'Tạm nghỉ' : 'Bật nhận ca'),
                          style: AppTextStyles.badgeText.copyWith(
                            color: isAvailable
                                ? AppColors.error
                                : AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Khối 4 chỉ số thống kê gọn nhẹ, có icon màu điểm nhấn
class _MetricsStrip extends StatelessWidget {
  final int upcomingCount;
  final int inProgressCount;
  final int totalGuests;
  final String avgRating;
  final int reviewCount;

  const _MetricsStrip({
    required this.upcomingCount,
    required this.inProgressCount,
    required this.totalGuests,
    required this.avgRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatCell(
        title: 'Ca sắp tới',
        value: '$upcomingCount',
        subtitle: 'Chờ khởi hành',
        icon: Icons.upcoming_rounded,
        accentColor: AppColors.info,
      ),
      _StatCell(
        title: 'Đang diễn ra',
        value: '$inProgressCount',
        subtitle: 'Ca tour hiện hành',
        icon: Icons.play_circle_fill_rounded,
        accentColor: AppColors.success,
        valueColor: AppColors.success,
      ),
      _StatCell(
        title: 'Tổng lượt khách',
        value: '$totalGuests',
        subtitle: 'Khách trong đoàn',
        icon: Icons.groups_rounded,
        accentColor: AppColors.primary,
      ),
      _StatCell(
        title: 'Đánh giá TB',
        value: '$avgRating / 5.0',
        subtitle: '$reviewCount phản hồi',
        icon: Icons.star_rounded,
        accentColor: AppColors.ratingStar,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        if (isWide) {
          return Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: items[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: items[0]),
                const SizedBox(width: 8),
                Expanded(child: items[1]),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: items[2]),
                const SizedBox(width: 8),
                Expanded(child: items[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color? valueColor;

  const _StatCell({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              fontSize: 19,
              color: valueColor ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 14,
          color: AppColors.ratingStar,
        ),
      ),
    );
  }
}

class _ScheduleItemCard extends StatelessWidget {
  final BuddySchedule schedule;
  final VoidCallback onOpenRoster;

  const _ScheduleItemCard({
    required this.schedule,
    required this.onOpenRoster,
  });

  Color get _statusColor => switch (schedule.status) {
        'IN_PROGRESS' => AppColors.success,
        'COMPLETED' => AppColors.neutralDark,
        _ => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    final checkedIn = schedule.checkedInCount;
    final total = schedule.totalGuests;
    final progress = total > 0 ? (checkedIn / total).clamp(0.0, 1.0) : 0.0;
    final dayStr = schedule.departureDate != null
        ? schedule.departureDate!.day.toString().padLeft(2, '0')
        : '--';
    final monthStr = schedule.departureDate != null
        ? 'Th${schedule.departureDate!.month}'
        : 'Tour';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ô lịch ngày khởi hành tông Navy + Trắng
              Container(
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      color: AppColors.primary,
                      child: Text(
                        monthStr,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.badgeText.copyWith(
                          fontSize: 10,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        dayStr,
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            BuddySchedule.statusLabel(schedule.status),
                            style: AppTextStyles.badgeText
                                .copyWith(color: _statusColor),
                          ),
                        ),
                        Text(
                          '${Formatters.time(schedule.startTime)} – ${Formatters.time(schedule.endTime)}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.activityTitle,
                      style: AppTextStyles.labelBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if ((schedule.location ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Điểm hẹn: ${schedule.location}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.caption,
                        children: [
                          const TextSpan(text: 'Sĩ số đoàn: '),
                          TextSpan(
                            text: '$checkedIn/$total',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? AppColors.success : AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onOpenRoster,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.groups_2_outlined,
                  size: 15,
                  color: AppColors.secondary,
                ),
                label: Text(
                  'Danh sách đoàn',
                  style: AppTextStyles.badgeText.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourMembersDialog extends StatefulWidget {
  final BuddySchedule schedule;
  final VoidCallback onChanged;

  const _TourMembersDialog({
    required this.schedule,
    required this.onChanged,
  });

  @override
  State<_TourMembersDialog> createState() => _TourMembersDialogState();
}

class _TourMembersDialogState extends State<_TourMembersDialog> {
  late Future<List<TourMember>> _future;
  final Set<String> _checkingIds = {};
  String? _bannerNotice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = getIt<BuddyRepository>().getTourMembers(widget.schedule.departureId);
  }

  void _showNotice(String text) {
    setState(() => _bannerNotice = text);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _bannerNotice == text) {
        setState(() => _bannerNotice = null);
      }
    });
  }

  Future<void> _copyText(String text, String notice) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showNotice(notice);
  }

  Future<void> _openGoogleMaps(String address) async {
    final encoded = Uri.encodeComponent('$address, Hồ Chí Minh, Việt Nam');
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    await launchUrl(uri);
  }

  Future<void> _checkIn(TourMember m) async {
    setState(() => _checkingIds.add(m.registrationId));
    try {
      await getIt<BuddyRepository>().checkInMember(
        widget.schedule.departureId,
        m.registrationId,
      );
      if (!mounted) return;
      _showNotice(
        m.isCheckedIn
            ? 'Đã hủy trạng thái đón của ${m.guestName}'
            : 'Đã điểm danh khách ${m.guestName}',
      );
      setState(_load);
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(readableError(e))),
      );
    } finally {
      if (mounted) setState(() => _checkingIds.remove(m.registrationId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    final dep = widget.schedule;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: FutureBuilder<List<TourMember>>(
          future: _future,
          builder: (context, snapshot) {
            final members = snapshot.data ?? const <TourMember>[];
            final presentCount = members.where((m) => m.isCheckedIn).length;
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. HEADER ──
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Formatters.date(dep.departureDate)} · ${Formatters.time(dep.startTime)} – ${Formatters.time(dep.endTime)}',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dep.activityTitle,
                              style: AppTextStyles.labelBold.copyWith(fontSize: 15),
                            ),
                            if ((dep.location ?? '').isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                dep.location!,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),

                // ── 2. ATTENDANCE SUMMARY BAR ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            const TextSpan(text: 'Đã đón / Có mặt: '),
                            TextSpan(
                              text: '$presentCount',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' / ${members.length} khách'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: isLoading ? null : () => setState(_load),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh_rounded,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                isLoading ? 'Đang tải...' : 'Làm mới',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 3. BODY (GUEST LIST) ──
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_bannerNotice != null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _bannerNotice!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (snapshot.hasError)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              readableError(snapshot.error!),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium,
                            ),
                          )
                        else if (members.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Chưa có khách đăng ký ca tour này.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium,
                            ),
                          )
                        else
                          ...members.map((m) {
                            final isPresent = m.isCheckedIn;
                            final busy = _checkingIds.contains(m.registrationId);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? AppColors.success.withValues(alpha: 0.05)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isPresent
                                      ? AppColors.success.withValues(alpha: 0.45)
                                      : AppColors.border,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tên khách + số lượng người
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 2,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              m.guestName,
                                              style: AppTextStyles.labelBold
                                                  .copyWith(fontSize: 14),
                                            ),
                                            Text(
                                              '(${m.adultCount} người lớn${m.childCount > 0 ? ', ${m.childCount} trẻ em' : ''})',
                                              style: AppTextStyles.caption,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Số điện thoại + Gọi / Sao chép
                                  if ((m.phoneNumber ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 12,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          m.phoneNumber!,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _callPhone(m.phoneNumber!),
                                          child: Text(
                                            'Gọi',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _copyText(
                                            m.phoneNumber!,
                                            'Đã sao chép SĐT ${m.phoneNumber}',
                                          ),
                                          child: Text(
                                            'Sao chép',
                                            style: AppTextStyles.caption.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  // Địa chỉ đón khách + Google Maps
                                  if ((m.pickupLocation ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(11),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFFDE68A),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.location_on_rounded,
                                                size: 16,
                                                color: Color(0xFFD97706),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'ĐỊA CHỈ ĐÓN KHÁCH',
                                                      style: AppTextStyles.badgeText
                                                          .copyWith(
                                                        color:
                                                            const Color(0xFF92400E),
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      m.pickupLocation!,
                                                      style: AppTextStyles.bodySmall
                                                          .copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color:
                                                            AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Divider(
                                            height: 1,
                                            color: Color(0xFFFDE68A),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 6,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                onTap: () => _openGoogleMaps(
                                                    m.pickupLocation!),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: AppColors.info
                                                          .withValues(alpha: 0.35),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.open_in_new_rounded,
                                                        size: 13,
                                                        color: AppColors.info,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Mở Google Maps chỉ đường',
                                                        style: AppTextStyles
                                                            .badgeText
                                                            .copyWith(
                                                          color: AppColors.info,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => _copyText(
                                                  m.pickupLocation!,
                                                  'Đã sao chép địa chỉ đón',
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 4,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.copy_rounded,
                                                        size: 13,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Sao chép',
                                                        style: AppTextStyles.caption
                                                            .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),

                                  // Trạng thái Điểm danh / Đã đón
                                  if (isPresent)
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withValues(alpha: 0.14),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: AppColors.success
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: AppColors.success,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Đã đón',
                                                style: AppTextStyles.badgeText
                                                    .copyWith(
                                                  color: AppColors.success,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (m.checkedInAt != null) ...[
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              Formatters.dateTime(m.checkedInAt),
                                              style: AppTextStyles.caption,
                                            ),
                                          ),
                                        ] else
                                          const Spacer(),
                                        TextButton(
                                          onPressed:
                                              busy ? null : () => _checkIn(m),
                                          style: TextButton.styleFrom(
                                            visualDensity: VisualDensity.compact,
                                            foregroundColor:
                                                AppColors.textSecondary,
                                          ),
                                          child: Text(
                                            busy ? '...' : 'Hủy đón',
                                            style: AppTextStyles.caption.copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            busy ? null : () => _checkIn(m),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(0, 38),
                                        ),
                                        icon: busy
                                            ? const SizedBox(
                                                width: 14,
                                                height: 14,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Icon(Icons.check_rounded,
                                                size: 16),
                                        label: const Text('Điểm danh / Đã đón'),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                // ── 4. FOOTER ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                      child: const Text('Đóng'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
