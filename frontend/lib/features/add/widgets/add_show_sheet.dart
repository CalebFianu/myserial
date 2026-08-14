import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_chip.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../../../shared/widgets/segmented_control.dart';

// Mock show data
const _searchableShows = [
  (id: 1, title: 'Severance', year: '2022', status: 'Returning', posterUrl: ''),
  (id: 2, title: 'The Bear', year: '2022', status: 'Returning', posterUrl: ''),
  (id: 3, title: 'Succession', year: '2018–2023', status: 'Ended', posterUrl: ''),
  (id: 4, title: 'Breaking Bad', year: '2008–2013', status: 'Ended', posterUrl: ''),
  (id: 5, title: 'The Wire', year: '2002–2008', status: 'Ended', posterUrl: ''),
  (id: 6, title: 'House of the Dragon', year: '2022', status: 'Returning', posterUrl: ''),
  (id: 7, title: 'Andor', year: '2022', status: 'Returning', posterUrl: ''),
];

class AddShowSheet extends ConsumerStatefulWidget {
  const AddShowSheet({super.key});

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List get _filteredShows => _searchableShows
      .where((s) =>
          _query.isEmpty ||
          s.title.toLowerCase().contains(_query.toLowerCase()))
      .toList();

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
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
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
            itemCount: _filteredShows.length,
            itemBuilder: (context, i) {
              final show = _filteredShows[i];
              final isDark = Theme.of(context).brightness == Brightness.dark;
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
                            '${show.year} · ${show.status}',
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected show card + Change button
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
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp4),

          // Mode segmented control
          SegmentedControl(
            options: const ['Watching', 'Watched', 'Add to list'],
            selectedIndex: _modeTab,
            onChanged: (i) => setState(() => _modeTab = i),
          ),
          const SizedBox(height: AppSpacing.sp5),

          // Mode content
          if (_modeTab == 0) _buildWatchingMode(isDark),
          if (_modeTab == 1) _buildWatchedMode(isDark),
          if (_modeTab == 2) _buildListMode(isDark),

          const SizedBox(height: AppSpacing.sp5),

          MsButton(
            label: 'Save',
            variant: MsButtonVariant.primary,
            size: MsButtonSize.lg,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchingMode(bool isDark) {
    final seasons = ['S1', 'S2', 'S3'];
    final episodes = List.generate(10, (i) => 'E${i + 1}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Season', style: AppTypography.captionSemiBold.copyWith(color: AppColors.fg3)),
        const SizedBox(height: AppSpacing.sp2),
        Wrap(
          spacing: AppSpacing.sp2,
          runSpacing: AppSpacing.sp2,
          children: seasons.asMap().entries.map((e) {
            return MsChip(
              label: e.value,
              selected: _selectedSeason == e.key + 1,
              small: true,
              onTap: () => setState(() {
                _selectedSeason = e.key + 1;
                _selectedEpisode = 0;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text('Last watched episode', style: AppTypography.captionSemiBold.copyWith(color: AppColors.fg3)),
        const SizedBox(height: AppSpacing.sp2),
        Wrap(
          spacing: AppSpacing.sp2,
          runSpacing: AppSpacing.sp2,
          children: episodes.asMap().entries.map((e) {
            return MsChip(
              label: e.value,
              selected: _selectedEpisode == e.key + 1,
              small: true,
              onTap: () => setState(() => _selectedEpisode = e.key + 1),
            );
          }).toList(),
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
        Text('Date finished', style: AppTypography.captionSemiBold.copyWith(color: AppColors.fg3)),
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
    final lists = ['Desert Island Picks', 'Best Season Finales', 'Watch with Partner'];
    final Set<String> checked = {};

    return StatefulBuilder(
      builder: (context, setSS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to list', style: AppTypography.captionSemiBold.copyWith(color: AppColors.fg3)),
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
