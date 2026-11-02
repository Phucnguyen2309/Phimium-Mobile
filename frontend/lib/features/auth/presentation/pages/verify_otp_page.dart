import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../bloc/auth_bloc.dart';

/// Nhập mã OTP 6 số BE gửi về email sau khi đăng ký
class VerifyOtpPage extends StatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final otp = _otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      AppFeedback.info(
        context,
        'Vui lòng nhập đủ mã OTP gồm 6 chữ số.',
        title: 'Mã OTP chưa hợp lệ',
      );
      return;
    }
    context.read<AuthBloc>().add(
          AuthVerifyOtpRequested(email: widget.email, otp: otp),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerified) {
          AppFeedback.success(
            context,
            'Xác thực email thành công! Mời bạn đăng nhập.',
            title: 'Hoàn tất đăng ký',
          );
          context.go(AppRouter.login);
        } else if (state is AuthError) {
          AppFeedback.error(
            context,
            state.message,
            title: 'Xác thực thất bại',
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text(AppStrings.otp)),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Xác thực Email',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Nhập mã 6 chữ số đã được gửi tới',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading2.copyWith(
                          letterSpacing: 10,
                          color: AppColors.primary,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '••••••',
                        ),
                        onSubmitted: (_) => _verify(),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: isLoading ? null : _verify,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(AppStrings.verify),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
