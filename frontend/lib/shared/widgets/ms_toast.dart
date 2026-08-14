import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/motion.dart';

class ToastData {
  const ToastData({
    required this.message,
    this.action,
    this.actionLabel,
    this.duration = const Duration(seconds: 4),
  });

  final String message;
  final VoidCallback? action;
  final String? actionLabel;
  final Duration duration;
}

final toastProvider =
    StateNotifierProvider<ToastNotifier, ToastData?>((ref) => ToastNotifier());

class ToastNotifier extends StateNotifier<ToastData?> {
  ToastNotifier() : super(null);

  void show(ToastData toast) {
    state = toast;
  }

  void dismiss() {
    state = null;
  }
}

class MsToastOverlay extends ConsumerStatefulWidget {
  const MsToastOverlay({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MsToastOverlay> createState() => _MsToastOverlayState();
}

class _MsToastOverlayState extends ConsumerState<MsToastOverlay> {
  @override
  Widget build(BuildContext context) {
    final toast = ref.watch(toastProvider);
    return Stack(
      children: [
        widget.child,
        if (toast != null)
          _ToastWidget(
            key: ValueKey(toast.message + DateTime.now().millisecondsSinceEpoch.toString()),
            data: toast,
            onDismiss: () => ref.read(toastProvider.notifier).dismiss(),
          ),
      ],
    );
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  final ToastData data;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppMotion.med,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: AppMotion.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.spring));

    _ctrl.forward();
    Future.delayed(widget.data.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _ctrl.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: AppSpacing.pageGutter,
      right: AppSpacing.pageGutter,
      bottom: bottomPad + 90, // above nav bar
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4,
                vertical: AppSpacing.sp3,
              ),
              decoration: BoxDecoration(
                color: AppColors.ink2,
                borderRadius: AppRadius.controlRR,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.data.message,
                      style: AppTypography.body.copyWith(
                        color: AppColors.fg1,
                      ),
                    ),
                  ),
                  if (widget.data.action != null &&
                      widget.data.actionLabel != null) ...[
                    const SizedBox(width: AppSpacing.sp3),
                    GestureDetector(
                      onTap: () {
                        widget.data.action!();
                        _dismiss();
                      },
                      child: Text(
                        widget.data.actionLabel!,
                        style: AppTypography.bodySemiBold.copyWith(
                          color: AppColors.signal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
