import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../features/lists/providers/lists_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/search/providers/search_provider.dart';
import '../../../features/show/providers/show_provider.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_chip.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../../../shared/widgets/segmented_control.dart';

class AddShowSheet extends ConsumerStatefulWidget {
  const AddShowSheet({
    super.key,
    this.initialQuery,
    this.preselectedShowId,
    this.preselectedShowTitle,
    this.preselectedShowPosterUrl,
  });

  final String? initialQuery;
  final int? preselectedShowId;
  final String? preselectedShowTitle;
  final String? preselectedShowPosterUrl;

  @override
  ConsumerState<AddShowSheet> createState() => _AddShowSheetState();
}

class _AddShowSheetState extends ConsumerState<AddShowSheet> {
  final _searchCtrl = TextEditingController();
  int? _selectedShowId;
  String? _selectedShowTitle;
  String? _selectedShowPosterUrl;
  int _modeTab = 0; // 0=Watching, 1=Watched, 2=Add to list
  int _selectedSeason = 1;
  int _selectedEpisode = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedShowId != null) {
      _selectedShowId = widget.preselectedShowId;
      _selectedShowTitle = widget.preselectedShowTitle;
      _selectedShowPosterUrl = widget.preselectedShowPosterUrl;
    } else if (widget.initialQuery != null &&
        widget.initialQuery!.isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchProvider.notifier).setQuery(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedShowId != null) {
      return _buildSelectedFlow();
    }
    return _buildSearchFlow();
  }

  Widget _buildSearchFlow() {
    final searchState = ref.watch(searchProvider);
    final results = searchState.showResults;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search TV shows...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        ref.read(searchProvider.notifier).setQuery('');
                      },
                    )
                  : null,
            ),
            onChanged: (q) => ref.read(searchProvider.notifier).setQuery(q),
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),

        if (searchState.isLoading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.sp6),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.signal),
            ),
          )
        else if (results.isEmpty && _searchCtrl.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp6),
            child: Center(
              child: Text(
                'No shows found',
                style: AppTypography.body.copyWith(color: AppColors.fg3),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final show = results[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      _selectedShowId = show.id;
                      _selectedShowTitle = show.title;
                      _selectedShowPosterUrl = show.posterUrl;
                    }),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: PosterPlaceholder(
                            title: show.title,
                            imageUrl: show.posterUrl,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(show.title, style: AppTypography.cardTitle),
                              Text(
                                [
                                  if (show.year != null) show.year!,
                                  if (show.status != null) show.status!,
                                ].join(' · '),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.signalSoft,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.signal.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.signal,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedFlow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showAsync = ref.watch(showDetailProvider(_selectedShowId!));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                child: PosterPlaceholder(
                  title: _selectedShowTitle,
                  imageUrl: _selectedShowPosterUrl,
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Text(
                  _selectedShowTitle ?? '',
                  style: AppTypography.heading,
                ),
              ),
              MsButton(
                label: 'Change',
                variant: MsButtonVariant.ghost,
                size: MsButtonSize.sm,
                onPressed: () => setState(() {
                  _selectedShowId = null;
                  _selectedShowTitle = null;
                  _selectedSeason = 1;
                  _selectedEpisode = 0;
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp4),

          SegmentedControl(
            options: const ['Watching', 'Watched', 'Add to list'],
            selectedIndex: _modeTab,
            onChanged: (i) => setState(() => _modeTab = i),
          ),
          const SizedBox(height: AppSpacing.sp5),

          showAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sp4),
                child: CircularProgressIndicator(color: AppColors.signal),
              ),
            ),
            error: (_, __) => Text(
              'Could not load show details.',
              style: AppTypography.body.copyWith(color: AppColors.fg2),
            ),
            data: (show) {
              if (_modeTab == 0) return _buildWatchingMode(isDark, show.seasons);
              if (_modeTab == 1) return _buildWatchedMode(isDark);
              return _buildListMode(isDark);
            },
          ),

          const SizedBox(height: AppSpacing.sp5),

          MsButton(
            label: _saving ? 'Saving...' : 'Save',
            variant: MsButtonVariant.primary,
            size: MsButtonSize.lg,
            fullWidth: true,
            onPressed: _saving ? null : _onSave,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchingMode(bool isDark, List<SeasonSummary> seasons) {
    final currentSeason = seasons.firstWhere(
      (s) => s.seasonNumber == _selectedSeason,
      orElse: () => seasons.isNotEmpty
          ? seasons.first
          : const SeasonSummary(
              id: 0,
              seasonNumber: 1,
              name: 'Season 1',
              episodeCount: 10,
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOW FAR ALONG ARE YOU?', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sp3),

        Text('Season', style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sp2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: seasons.map((s) {
            return MsChip(
              label: 'S${s.seasonNumber}',
              selected: s.seasonNumber == _selectedSeason,
              onTap: () => setState(() {
                _selectedSeason = s.seasonNumber;
                _selectedEpisode = 0;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sp4),

        Text('Episode', style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sp2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(currentSeason.episodeCount, (i) {
            final epNum = i + 1;
            return MsChip(
              label: 'E$epNum',
              selected: epNum == _selectedEpisode,
              onTap: () => setState(() => _selectedEpisode = epNum),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWatchedMode(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mark all episodes as watched and add to your history.',
          style: AppTypography.body.copyWith(color: AppColors.fg2),
        ),
      ],
    );
  }

  Widget _buildListMode(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELECT A LIST', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sp3),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MsChip(
              label: 'Watchlist',
              selected: true,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onSave() async {
    if (_selectedShowId == null) return;
    setState(() => _saving = true);

    try {
      final api = ref.read(apiClientProvider);
      if (_modeTab == 0) {
        // Watching mode: track show and mark progress up to selected episode
        await api.post('/binge/$_selectedShowId');
        if (_selectedEpisode > 0) {
          await api.post('/watch/progress', data: {
            'showId': _selectedShowId,
            'seasonNumber': _selectedSeason,
            'episodeNumber': _selectedEpisode,
          });
        }
      } else if (_modeTab == 1) {
        // Watched mode: track show and mark entire show as watched
        await api.post('/binge/$_selectedShowId');
        await api.post('/watch/show/$_selectedShowId');
      } else {
        // Add to watchlist
        await api.post('/lists/watchlist/$_selectedShowId');
      }

      ref.invalidate(profileProvider);
      ref.invalidate(listsProvider);
      ref.invalidate(showDetailProvider(_selectedShowId!));

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      // Error handled
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
