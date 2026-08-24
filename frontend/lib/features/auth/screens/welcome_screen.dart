import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../design/motion.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../providers/auth_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: Stack(
        children: [
          // Rotated poster grid backdrop
          const _PosterGridBackdrop(),
          // Bottom gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ink0.withOpacity(0),
                    AppColors.ink0.withOpacity(0.85),
                    AppColors.ink0,
                  ],
                  stops: const [0.0, 0.4, 0.7],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Wordmark
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'MySerial',
                          style: AppTypography.hero.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: '.',
                          style: AppTypography.hero.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.signal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Text(
                    'Track every episode, rate as you go, '
                    'and never get spoiled. Your TV journey, '
                    'beautifully organized.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.fg2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp7),
                  MsButton(
                    label: 'Create account',
                    variant: MsButtonVariant.primary,
                    size: MsButtonSize.lg,
                    fullWidth: true,
                    onPressed: () => _showAuthSheet(context, isLogin: false),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  MsButton(
                    label: 'I already have an account',
                    variant: MsButtonVariant.ghost,
                    size: MsButtonSize.lg,
                    fullWidth: true,
                    onPressed: () => _showAuthSheet(context, isLogin: true),
                  ),
                  const SizedBox(height: AppSpacing.sp6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthSheet(BuildContext context, {required bool isLogin}) {
    MsSheet.show(
      context,
      title: isLogin ? 'Sign in' : 'Create account',
      child: _AuthSheetContent(isLogin: isLogin),
    );
  }
}

// ── Poster Grid Backdrop ─────────────────────────────────────────────────────

class _PosterGridBackdrop extends StatelessWidget {
  const _PosterGridBackdrop();

  static const _posterColors = [
    Color(0xFF1D2530),
    Color(0xFF28323F),
    Color(0xFF141A21),
    Color(0xFF1A2236),
    Color(0xFF232D3C),
    Color(0xFF1B2634),
  ];

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    const cols = 4;
    const posterW = 90.0;
    const posterH = posterW / (2 / 3);
    const gap = 8.0;

    return Positioned.fill(
      child: Opacity(
        opacity: 0.5,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(-8 * math.pi / 180)
            ..scale(1.35),
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: SizedBox(
              width: screen.width * 1.5,
              height: screen.height * 1.5,
              child: Wrap(
                spacing: gap,
                runSpacing: gap,
                children: List.generate(
                  cols * 14,
                  (i) => Container(
                    width: posterW,
                    height: posterH,
                    decoration: BoxDecoration(
                      color: _posterColors[i % _posterColors.length],
                      borderRadius: BorderRadius.circular(AppRadius.poster),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _posterColors[i % _posterColors.length],
                          _posterColors[(i + 2) % _posterColors.length],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Auth Sheet Content ────────────────────────────────────────────────────────

class _AuthSheetContent extends ConsumerStatefulWidget {
  const _AuthSheetContent({required this.isLogin});
  final bool isLogin;

  @override
  ConsumerState<_AuthSheetContent> createState() => _AuthSheetContentState();
}

class _AuthSheetContentState extends ConsumerState<_AuthSheetContent> {
  late bool _isLogin;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await ref.read(authProvider.notifier).login(
              email: _emailCtrl.text.trim(),
              password: _passCtrl.text,
            );
      } else {
        await ref.read(authProvider.notifier).register(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passCtrl.text,
            );
      }
      if (mounted) {
        Navigator.of(context).pop();
        context.go(_isLogin ? '/home' : '/onboarding');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.pageGutter,
        right: AppSpacing.pageGutter,
        bottom: MediaQuery.viewInsetsOf(context).bottom +
            AppSpacing.pageGutter,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isLogin) ...[
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: AppSpacing.sp3),
            ],
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Valid email required' : null,
            ),
            const SizedBox(height: AppSpacing.sp3),
            TextFormField(
              controller: _passCtrl,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              obscureText: _obscurePass,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => v == null || v.length < 6
                  ? 'At least 6 characters'
                  : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sp3),
              Text(
                _error!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.alertColor,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sp5),
            MsButton(
              label: _isLogin ? 'Sign in' : 'Create account',
              variant: MsButtonVariant.primary,
              size: MsButtonSize.lg,
              fullWidth: true,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.sp3),
            MsButton(
              label: 'Continue with Apple',
              variant: MsButtonVariant.secondary,
              size: MsButtonSize.lg,
              fullWidth: true,
              leading: const Icon(Icons.apple, size: 20),
              onPressed: () {}, // placeholder
            ),
            const SizedBox(height: AppSpacing.sp5),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Sign in',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
