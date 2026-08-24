import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../features/search/providers/search_provider.dart';
import '../../../features/show/providers/show_provider.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_chip.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../../../shared/widgets/segmented_control.dart';

class AddShowSheet extends ConsumerStatefulWidget {
  const AddShowSheet({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<AddShowSheet> createState() => _AddShowSheetState();
}

class _AddShowSheetState extends ConsumerState<AddShowSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
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
    if (widget.initialQuery != null) {
      _searchCtrl.text = widget.initialQuery!;
      _query = widget.initialQuery!;
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
    return MsSheet(
      title: 'Add a show',
      showHandle: true,
      showCloseButton: true,
      child: _selectedShowId == null
          ? _buildSearch()
          : _buildSelectedFlow(),
    );
  }

  Widget _buildSearch() {
    final searchState = ref.watch(searchProvider);
    final results = _query.isEmpty ? <ShowResult>[] : searchState.showResults;
    final isLoading = searchState.isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) {
              setState(() => _query = v);
              ref.read(searchProvider.notifier).setQuery(v);
            },
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search shows...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                        ref.read(searchProvider.notifier).setQuery('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        if (isLoading && _query.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sp4),
            child: CircularProgressIndicator(color: AppColors.signal),
          )
        else if (_query.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: Text(
              'Search for a show to add.',
              style: AppTypography.body.copyWith(color: AppColors.fg2),
              textAlign: TextAlign.center,
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
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedShowId = show.id;
                          _selectedShowTitle = show.title;
                          _selectedShowPosterUrl = show.posterUrl;
                        }),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.signalSoft,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.signal.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.signal,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
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

  Future<void> _onSave() async {
    if (_selectedShowId == null) return;
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      // Track the show (creates BingeTrack)
      await api.post('/binge/$_selectedShowId');

      if (_modeTab == 2) {
        // "Add to list" mode — add to watchlist
        await api.post('/lists/watchlist/$_selectedShowId');
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      setState(() => _saving = false);
    }
  }

  Widget _buildWatchingMode(bool isDark, List<SeasonSummary> seasons) {
    if (seasons.isEmpty) {
      return Text(
        'No season data available.',
        style: AppTypography.body.copyWith(color: AppColors.fg2),
      );
    }

    // Find the selected season's episode count
    final selectedSeasonData = seasons.firstWhere(
      (s) => s.seasonNumber == _selectedSeason,
      orElse: () => seasons.first,
    );
    final episodeCount = selectedSeasonData.episodeCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Season',
            style:
                AppTypography.captionSemiBold.copyWith(color: AppColors.fg3)),
        const SizedBox(height: AppSpacing.sp2),
        Wrap(
          spacing: AppSpacing.sp2,
          runSpacing: AppSpacing.sp2,
          children: seasons.map((s) {
            return MsChip(
              label: 'S${s.seasonNumber}',
              selected: _selectedSeason == s.seasonNumber,
              small: true,
              onTap: () => setState(() {
                _selectedSeason = s.seasonNumber;
                _selectedEpisode = 0;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text('Last watched episode',
            style:
                AppTypography.captionSemiBold.copyWith(color: AppColors.fg3)),
        const SizedBox(height: AppSpacing.sp2),
        Wrap(
          spacing: AppSpacing.sp2,
          runSpacing: AppSpacing.sp2,
          children: List.generate(episodeCount, (i) {
            final epNum = i + 1;
            return MsChip(
              label: 'E$epNum',
              selected: _selectedEpisode == epNum,
              small: true,
              onTap: () => setState(() => _selectedEpisode = epNum),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sp3),
        if (_selectedEpisode > 0)
          Text(
            'Will mark S${_selectedSeason.toString().padLeft(2, '0')}E01 through S${_selectedSeason.toString().padLeft(2, '0')}E${_selectedEpisode.toString().padLeft(2, '0')} as watched.',
            style: AppTypography.caption.copyWith(color: AppColors.track),
          ),
      ],
    );
  }

  Widget _buildWatchedMode(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mark entire series as watched.',
          style: AppTypography.body.copyWith(color: AppColors.fg2),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text('Date finished',
            style:
                AppTypography.captionSemiBold.copyWith(color: AppColors.fg3)),
        const SizedBox(height: AppSpacing.sp2),
        Wrap(
          spacing: AppSpacing.sp2,
          children: ['Today', 'Yesterday', 'Last week'].map((s) {
            return MsChip(label: s, small: true, onTap: () {});
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListMode(bool isDark) {
    const lists = ['Desert Island Picks', 'Best Season Finales', 'Watch with Partner'];
    final Set<String> checked = {};

    return StatefulBuilder(
      builder: (context, setSS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to list',
              style: AppTypography.captionSemiBold
                  .copyWith(color: AppColors.fg3)),
          const SizedBox(height: AppSpacing.sp2),
          ...lists.map((list) {
            final isChecked = checked.contains(list);
            return CheckboxListTile(
              value: isChecked,
              onChanged: (v) => setSS(() {
                if (v == true) {
                  checked.add(list);
                } else {
                  checked.remove(list);
                }
              }),
              title: Text(list, style: AppTypography.body),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
        ],
      ),
    );
  }
}
