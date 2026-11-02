import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Hệ thống Popup xác nhận & Thông báo nổi (Toast / Alert) đồng bộ giao diện Web Phimium
class AppFeedback {
  AppFeedback._();

  /// Thông báo thành công (màu xanh Emerald, icon tích tròn)
  static void success(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _showToast(
      context,
      title: title ?? 'Thành công',
      message: message,
      icon: Icons.check_circle_rounded,
      accent: AppColors.success,
      bgTint: const Color(0xFFECFDF5),
      borderTint: const Color(0xFFA7F3D0),
    );
  }

  /// Thông báo lỗi (màu đỏ Rose, icon cảnh báo)
  static void error(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _showToast(
      context,
      title: title ?? 'Có lỗi xảy ra',
      message: message,
      icon: Icons.error_outline_rounded,
      accent: AppColors.error,
      bgTint: const Color(0xFFFFF1F2),
      borderTint: const Color(0xFFFECDD3),
    );
  }

  /// Thông báo thông tin / nhắc nhở (màu Navy / Blue)
  static void info(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _showToast(
      context,
      title: title ?? 'Thông báo',
      message: message,
      icon: Icons.info_outline_rounded,
      accent: AppColors.primary,
      bgTint: const Color(0xFFF8FAFC),
      borderTint: AppColors.border,
    );
  }

  static void _showToast(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color accent,
    required Color bgTint,
    required Color borderTint,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderTint, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderTint),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelBold.copyWith(
                        color: accent,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textHint,
                ),
                onPressed: () => messenger.hideCurrentSnackBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hộp thoại xác nhận đồng bộ phong cách Modal trên Web
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Hủy',
    bool isDanger = false,
    IconData? icon,
  }) async {
    final accent = isDanger ? AppColors.error : AppColors.primary;
    final badgeBg = isDanger
        ? const Color(0xFFFFF1F2)
        : AppColors.primary.withValues(alpha: 0.08);
    final chosenIcon = icon ??
        (isDanger
            ? Icons.warning_amber_rounded
            : Icons.help_outline_rounded);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(chosenIcon, color: accent, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading3.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Text(cancelLabel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result == true;
  }
}

