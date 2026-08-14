import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/motion.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

enum NavTab { home, search, activity, profile }

class GlassBottomNav extends StatefulWidget {
  const GlassBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    required this.onAddPressed,
  });

  final NavTab currentTab;
  final ValueChanged<NavTab> onTabChanged;
  final VoidCallback onAddPressed;

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav> {
  bool _addPressed = false;

  static const _tabs = [
    NavTab.home,
    NavTab.search,
    NavTab.activity,
    NavTab.profile,
  ];

  static const _tabLabels = ['Home', 'Search', 'Activity', 'Profile'];

  static const _tabIconsFilled = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  static const _tabIconsOutline = [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.notifications_outlined,
    Icons.person_outline_rounded,
  ];

  int get _currentIndex =>
      _tabs.indexOf(widget.currentTab);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor =
        isDark ? AppColors.navGlassDark : AppColors.navGlassLight;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: AppSpacing.pageGutter,
      right: AppSpacing.pageGutter,
      bottom: bottomPad + AppSpacing.sp4,
      child: ClipRRect(
        borderRadius: AppRadius.pillRR,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: AppRadius.pillRR,
              border: Border.all(
                color: (isDark ? AppColors.inkLine : AppColors.paperLine)
                    .withOpacity(0.5),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 5 slots: home, search, [add], activity, profile
                final slotWidth = constraints.maxWidth / 5;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Sliding indicator
                    AnimatedPositioned(
                      duration: AppMotion.fast,
                      curve: AppMotion.spring,
                      left: _slotLeft(_currentIndex, slotWidth),
                      top: 6,
                      bottom: 6,
                      width: slotWidth - 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.signalSoft,
                          borderRadius: AppRadius.pillRR,
                        ),
                      ),
                    ),

                    // Tab buttons
                    Row(
                      children: [
                        // Home, Search
                        ..._buildTabButtons(0, 2, slotWidth),
                        // Add button (center)
                        SizedBox(
                          width: slotWidth,
                          child: _AddButton(
                            pressed: _addPressed,
                            onPressed: widget.onAddPressed,
                          ),
                        ),
                        // Activity, Profile
                        ..._buildTabButtons(2, 4, slotWidth),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _slotLeft(int tabIndex, double slotWidth) {
    // Slots: 0=home, 1=search, 2=add(skip), 3=activity, 4=profile
    // tab 0,1 → slots 0,1; tab 2,3 → slots 3,4
    final slot = tabIndex < 2 ? tabIndex : tabIndex + 1;
    return slot * slotWidth + 4;
  }

  List<Widget> _buildTabButtons(int from, int to, double slotWidth) {
    return List.generate(to - from, (i) {
      final tabIdx = from + i;
      final tab = _tabs[tabIdx];
      final isSelected = widget.currentTab == tab;

      return SizedBox(
        width: slotWidth,
        child: GestureDetector(
          onTap: () => widget.onTabChanged(tab),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? _tabIconsFilled[tabIdx]
                    : _tabIconsOutline[tabIdx],
                color: isSelected
                    ? AppColors.signal
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.fg3
                        : AppColors.lightFg3,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                _tabLabels[tabIdx],
                style: AppTypography.micro.copyWith(
                  color: isSelected
                      ? AppColors.signal
                      : Theme.of(context).brightness == Brightness.dark
                          ? AppColors.fg3
                          : AppColors.lightFg3,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.pressed, required this.onPressed});
  final bool pressed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedScale(
        scale: pressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.signal,
              borderRadius: AppRadius.pillRR,
              boxShadow: [
                BoxShadow(
                  color: AppColors.signal.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
