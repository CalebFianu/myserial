import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../providers/show_provider.dart';

class CastCrewScreen extends ConsumerStatefulWidget {
  const CastCrewScreen({super.key, required this.showId});
  final int showId;

  @override
  ConsumerState<CastCrewScreen> createState() => _CastCrewScreenState();
}

class _CastCrewScreenState extends ConsumerState<CastCrewScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAsync = ref.watch(showDetailProvider(widget.showId));
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: showAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) => const Center(child: Text('Error')),
        data: (show) {
          final filteredCast = show.cast
              .where((m) =>
                  _query.isEmpty ||
                  m.name.toLowerCase().contains(_query.toLowerCase()) ||
                  m.character.toLowerCase().contains(_query.toLowerCase()))
              .toList();
          final filteredCrew = show.crew
              .where((m) =>
                  _query.isEmpty ||
                  m.name.toLowerCase().contains(_query.toLowerCase()) ||
                  m.job.toLowerCase().contains(_query.toLowerCase()))
              .toList();

          return CustomScrollView(
            slivers: [
              // Sticky glass header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeader(
                  topPad: topPad,
                  title: 'Cast & crew',
                  onBack: () => context.pop(),
                  searchCtrl: _searchCtrl,
                  onSearch: (v) => setState(() => _query = v),
                ),
              ),

              // Cast group
              if (filteredCast.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageGutter,
                      AppSpacing.sp5,
                      AppSpacing.pageGutter,
                      AppSpacing.sp3,
                    ),
                    child: Text('CAST', style: AppTypography.overline),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final m = filteredCast[i];
                      return GestureDetector(
                        onTap: () => context.push('/person/${m.id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageGutter,
                            vertical: AppSpacing.sp2,
                          ),
                          child: Row(
                            children: [
                              MsAvatar(
                                name: m.name,
                                imageUrl: m.avatarUrl,
                                size: 44,
                              ),
                              const SizedBox(width: AppSpacing.sp3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name, style: AppTypography.body),
                                    Text(
                                      m.character,
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.fg3,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredCast.length,
                  ),
                ),
              ],

              // Crew group
              if (filteredCrew.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageGutter,
                      AppSpacing.sp6,
                      AppSpacing.pageGutter,
                      AppSpacing.sp3,
                    ),
                    child: Text('CREW', style: AppTypography.overline),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final m = filteredCrew[i];
                      return GestureDetector(
                        onTap: () => context.push('/person/${m.id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageGutter,
                            vertical: AppSpacing.sp2,
                          ),
                          child: Row(
                            children: [
                              MsAvatar(
                                name: m.name,
                                imageUrl: m.avatarUrl,
                                size: 44,
                              ),
                              const SizedBox(width: AppSpacing.sp3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name, style: AppTypography.body),
                                    Text(
                                      '${m.job} · ${m.department}',
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredCrew.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.bottomContentPad),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StickyHeader extends SliverPersistentHeaderDelegate {
  const _StickyHeader({
    required this.topPad,
    required this.title,
    required this.onBack,
    required this.searchCtrl,
    required this.onSearch,
  });

  final double topPad;
  final String title;
  final VoidCallback onBack;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;

  @override
  double get minExtent => topPad + 110;
  @override
  double get maxExtent => topPad + 110;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.navGlassDark,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              topPad + AppSpacing.sp3,
              AppSpacing.pageGutter,
              AppSpacing.sp3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.fg2,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Text(title, style: AppTypography.heading),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp3),
                TextField(
                  controller: searchCtrl,
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Filter by name...',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyHeader oldDelegate) => false;
}
