import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// Reusable error state widget with retry button
class ErrorStateWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textHint),
            const SizedBox(height: AppDimens.df),
            Text(
              message ?? AppStrings.errorGeneric,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimens.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String? message;
  final IconData icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.icon = Icons.luggage_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textHint),
            const SizedBox(height: AppDimens.df),
            Text(
              message ?? AppStrings.errorEmpty,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (action != null) ...[
              const SizedBox(height: AppDimens.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state widget
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            if (message != null) ...[
              const SizedBox(height: AppDimens.df),
              Text(message!, style: AppTextStyles.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// FutureBuilder gọn: tự hiện loading / lỗi (có nút thử lại) / rỗng
class AsyncView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final Widget? loading;

  const AsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.onRetry,
    this.isEmpty,
    this.empty,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loading ?? const LoadingWidget();
        }
        if (snapshot.hasError) {
          return ErrorStateWidget(
            message: readableError(snapshot.error!),
            onRetry: onRetry,
          );
        }
        final data = snapshot.data as T;
        if (isEmpty != null && isEmpty!(data)) {
          return empty ?? const EmptyStateWidget();
        }
        return builder(context, data);
      },
    );
  }
}
