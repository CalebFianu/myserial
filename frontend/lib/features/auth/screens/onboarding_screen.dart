import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../design/motion.dart';
import '../../../features/add/widgets/add_show_sheet.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../providers/auth_provider.dart';

// Mock show data for onboarding picker
const _popularShows = [
  (title: 'Breaking Bad', year: '2008', imageUrl: ''),
  (title: 'The Wire', year: '2002', imageUrl: ''),
  (title: 'Succession', year: '2018', imageUrl: ''),
  (title: 'Severance', year: '2022', imageUrl: ''),
  (title: 'The Bear', year: '2022', imageUrl: ''),
  (title: 'House of the Dragon', year: '2022', imageUrl: ''),
  (title: 'Andor', year: '2022', imageUrl: ''),
  (title: 'Slow Horses', year: '2022', imageUrl: ''),
  (title: 'The Rehearsal', year: '2022', imageUrl: ''),
  (title: 'White Lotus', year: '2021', imageUrl: ''),
  (title: 'Euphoria', year: '2019', imageUrl: ''),
  (title: 'Fleabag', year: '2016', imageUrl: ''),
];

const _tourCards = [
  (
    icon: Icons.check_circle_outline_rounded,
    title: 'Track every episode',
    body:
        'Mark episodes as watched, build your history, and see exactly where you are in any show.',
  ),
  (
    icon: Icons.auto_stories_outlined,
    title: 'Spoiler-free recaps',
    body:
        'Get caught up without fear. Recaps only show what you\'ve already watched.',
  ),
  (
    icon: Icons.notifications_active_outlined,
    title: 'Binge alerts',
    body:
        'Know the moment a show you\'re following drops a full season so you can dive in.',
  ),
  (
    icon: Icons.people_outline_rounded,
    title: 'Watch with friends',
    body:
        'See what your friends are watching, share ratings, and never watch alone.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _showPicker = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _pageCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _tourCards.length - 1) {
      _pageCtrl.nextPage(
        duration: AppMotion.med,
        curve: AppMotion.spring,
      );
    } else {
      setState(() => _showPicker = true);
    }
  }

  void _finish() async {
    await ref.read(authProvider.notifier).completeOnboarding();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: AnimatedSwitcher(
        duration: AppMotion.med,
        child: _showPicker ? _buildPicker() : _buildTour(),
      ),
    );
  }

  Widget _buildTour() {
    return SafeArea(
      child: Column(
        children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => setState(() => _showPicker = true),
              child: Text(
                'Skip',
                style: AppTypography.body.copyWith(color: AppColors.fg3),
              ),
            ),
          ),
          // Page view
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _tourCards.length,
              itemBuilder: (context, i) {
                final card = _tourCards[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter * 1.5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.signalSoft,
                          borderRadius: AppRadius.cardRR,
                        ),
                        child: Icon(
                          card.icon,
                          color: AppColors.signal,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp6),
                      Text(
                        card.title,
                        style: AppTypography.title,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        card.body,
                        style: AppTypography.body
                            .copyWith(color: AppColors.fg2),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _tourCards.length,
              (i) => AnimatedContainer(
                duration: AppMotion.fast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? AppColors.signal
                      : AppColors.fg3,
                  borderRadius: AppRadius.pillRR,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp6),
          // Next button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: MsButton(
              label: _currentPage == _tourCards.length - 1
                  ? 'Pick your first show'
                  : 'Next',
              variant: MsButtonVariant.primary,
              size: MsButtonSize.lg,
              fullWidth: true,
              onPressed: _nextPage,
            ),
          ),
          const SizedBox(height: AppSpacing.sp6),
        ],
      ),
    );
  }

  void _openAddSheet(String showTitle) async {
    await MsSheet.show(
      context,
      title: 'Add show',
      child: AddShowSheet(initialQuery: showTitle),
    );
    if (mounted) {
      await ref.read(authProvider.notifier).completeOnboarding();
      if (mounted) context.go('/home');
    }
  }

  Widget _buildPicker() {
    final filtered = _popularShows
        .where((s) =>
            _searchQuery.isEmpty ||
            s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.sp4,
              AppSpacing.pageGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pick your first show', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sp2),
                Text(
                  'Tap a show to get started.',
                  style: AppTypography.body.copyWith(color: AppColors.fg2),
                ),
                const SizedBox(height: AppSpacing.sp4),
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search shows...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sp3),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sp3,
                mainAxisSpacing: AppSpacing.sp3,
                childAspectRatio: 2 / 3,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final show = filtered[i];
                return PosterPlaceholder(
                  title: show.title,
                  imageUrl: show.imageUrl,
                  onTap: () => _openAddSheet(show.title),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            child: MsButton(
              label: 'Skip',
              variant: MsButtonVariant.ghost,
              size: MsButtonSize.lg,
              fullWidth: true,
              onPressed: _finish,
            ),
          ),
        ],
      ),
    );
  }
}
