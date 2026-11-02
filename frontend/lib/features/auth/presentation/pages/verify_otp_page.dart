import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP gồm 6 chữ số')),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(email: widget.email, otp: otp));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xác thực thành công! Mời bạn đăng nhập.')),
          );
          context.go(AppRouter.login);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.otp)),
          body: Padding(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nhập mã 6 số đã gửi tới', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimens.xs),
                Text(widget.email, style: AppTextStyles.labelBold),
                const SizedBox(height: AppDimens.xl),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading2.copyWith(letterSpacing: 8),
                  decoration: const InputDecoration(counterText: '', hintText: '______'),
                ),
                const SizedBox(height: AppDimens.xl),
                ElevatedButton(
                  onPressed: isLoading ? null : _verify,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                        )
                      : const Text(AppStrings.verify),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
