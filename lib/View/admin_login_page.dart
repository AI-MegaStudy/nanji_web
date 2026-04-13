import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../VM/admin_auth_viewmodel.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<AdminAuthViewModel>();
    await vm.signIn(
      adminId: _idController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAuthViewModel>();
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: isCompact
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IntroCard(isCompact: true),
                        const SizedBox(height: 20),
                        _LoginCard(
                          idController: _idController,
                          passwordController: _passwordController,
                          onSubmit: _submit,
                          isSubmitting: vm.isSubmitting,
                          errorMessage: vm.errorMessage,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _IntroCard(isCompact: false)),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 430,
                          child: _LoginCard(
                            idController: _idController,
                            passwordController: _passwordController,
                            onSubmit: _submit,
                            isSubmitting: vm.isSubmitting,
                            errorMessage: vm.errorMessage,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 28 : 36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB5E0F5), Color(0xFFE8F5FB)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 38,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            '자리난지 관리자',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '운영 현황, 예측 분석, 사용자 활동을 한 화면에서 확인할 수 있는 관리자 대시보드입니다.',
            style: TextStyle(
              fontSize: 16,
              height: 1.65,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FeatureChip(icon: Icons.dashboard_rounded, label: '운영 지표 확인'),
              _FeatureChip(icon: Icons.people_alt_rounded, label: '사용자 행동 분석'),
              _FeatureChip(icon: Icons.bolt_rounded, label: '실시간 활동 모니터링'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0F172A)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.idController,
    required this.passwordController,
    required this.onSubmit,
    required this.isSubmitting,
    required this.errorMessage,
  });

  final TextEditingController idController;
  final TextEditingController passwordController;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관리자 로그인',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '회사에서 발급한 관리자 ID와 비밀번호를 입력해 주세요.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          _LabeledField(
            label: '관리자 ID',
            child: TextField(
              controller: idController,
              decoration: _inputDecoration('관리자 ID를 입력해 주세요'),
            ),
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: '비밀번호',
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputDecoration('비밀번호를 입력해 주세요'),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F7A9A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '로그인',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7CC5E6), width: 1.6),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
