import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  DateTime? _birthday;
  bool _obscure = true;

  // Khớp regex của BE (RegisterRequest)
  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
  static final _phoneRegex = RegExp(r'^0[35789]\d{8}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 16, now.month, now.day),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  void _onRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthday == null) {
      AppFeedback.info(
        context,
        'Vui lòng chọn ngày sinh của bạn để tiếp tục.',
        title: 'Thiếu thông tin',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          birthday: _birthday!,
          phone: _phoneController.text.trim(),
        ));
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          AppFeedback.success(
            context,
            'Mã xác thực OTP đã được gửi tới ${state.email}',
            title: 'Đăng ký thành công',
          );
          context.pushReplacement(
            '${AppRouter.verifyOtp}?email=${Uri.encodeComponent(state.email)}',
          );
        } else if (state is AuthError) {
          AppFeedback.error(
            context,
            state.message,
            title: 'Đăng ký chưa thành công',
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(AppRouter.login),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.lg,
                0,
                AppDimens.lg,
                AppDimens.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 1. HEADER ĐỒNG BỘ VỚI TRANG ĐĂNG NHẬP ──
                      const _RegisterBrandHeader(),
                      const SizedBox(height: 18),

                      // ── 2. THẺ FORM ĐĂNG KÝ GỌN HỢP LÝ ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _fieldLabel(AppStrings.fullName),
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: 'Nguyễn Văn A',
                                  prefixIcon: Icon(Icons.person_outline, size: 20),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().length < 2)
                                        ? 'Họ tên tối thiểu 2 ký tự'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              _fieldLabel(AppStrings.email),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: 'ban@email.com',
                                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                                ),
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? 'Email không hợp lệ'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              // Hàng đôi: Số điện thoại + Ngày sinh (tiết kiệm chiều dọc trên app)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 11,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _fieldLabel(AppStrings.phone),
                                        TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            hintText: '0901234567',
                                            prefixIcon: Icon(
                                              Icons.phone_outlined,
                                              size: 19,
                                            ),
                                          ),
                                          validator: (v) => (v == null ||
                                                  !_phoneRegex
                                                      .hasMatch(v.trim()))
                                              ? 'SĐT 10 số hợp lệ'
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 10,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _fieldLabel(AppStrings.birthday),
                                        InkWell(
                                          onTap: _pickBirthday,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.calendar_today_outlined,
                                                size: 18,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 14,
                                              ),
                                            ),
                                            child: Text(
                                              _birthday == null
                                                  ? 'Chọn ngày'
                                                  : Formatters.date(_birthday),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: _birthday == null
                                                  ? AppTextStyles.bodySmall
                                                      .copyWith(
                                                      color: AppColors.textHint,
                                                    )
                                                  : AppTextStyles.bodyMedium
                                                      .copyWith(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _fieldLabel(AppStrings.password),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Ít nhất 8 ký tự (chữ, số, ký tự ĐB)',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || !_passwordRegex.hasMatch(v))
                                        ? 'Tối thiểu 8 ký tự, gồm chữ, số và ký tự đặc biệt'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              _fieldLabel(AppStrings.confirmPassword),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscure,
                                onFieldSubmitted: (_) => _onRegister(),
                                decoration: const InputDecoration(
                                  hintText: 'Nhập lại mật khẩu',
                                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                                ),
                                validator: (v) => v != _passwordController.text
                                    ? 'Mật khẩu không khớp'
                                    : null,
                              ),
                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: isLoading ? null : _onRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.2,
                                        ),
                                      )
                                    : const Text(AppStrings.register),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── 3. LINK CHUYỂN SANG ĐĂNG NHẬP ──
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAccount,
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.canPop()
                                ? context.pop()
                                : context.go(AppRouter.login),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.secondary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                AppStrings.login,
                                style: AppTextStyles.labelBold.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _RegisterBrandHeader extends StatelessWidget {
  const _RegisterBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset('assets/images/logo.png', width: 58, height: 58),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PHIMIUM SAIGON TRAVEL',
                style: AppTextStyles.badgeText.copyWith(
                  color: AppColors.secondary,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tạo tài khoản mới',
          style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 2),
        Text(
          'Khám phá Sài Gòn bản địa cùng đội ngũ Buddy thân thiện',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
