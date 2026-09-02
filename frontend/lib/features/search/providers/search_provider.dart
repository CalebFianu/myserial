import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/tmdb_image.dart';

// ── Models ────────────────────────────────────────────────────────────

enum SearchTab { shows, people }

class ShowResult {
  const ShowResult({
    required this.id,
    required this.title,
    this.posterUrl,
    this.year,
    this.status,
    this.overview,
    this.voteAverage,
  });
  final int id;
  final String title;
  final String? posterUrl;
  final String? year;
  final String? status;
  final String? overview;
  final double? voteAverage;

  factory ShowResult.fromJson(Map<String, dynamic> json) {
    final firstAirDate = json['firstAirDate'] as String?;
    final year =
        (firstAirDate != null && firstAirDate.length >= 4)
            ? firstAirDate.substring(0, 4)
            : null;
    return ShowResult(
      id: (json['id'] as num?)?.toInt() ?? (json['tmdbId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      posterUrl: tmdbImage(json['posterPath'] as String?),
      year: year,
      status: json['status'] as String?,
      overview: json['overview'] as String?,
      voteAverage: (json['voteAverage'] as num?)?.toDouble(),
    );
  }
}

class PersonResult {
  const PersonResult({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.knownFor,
  });
  final int id;
  final String name;
  final String? avatarUrl;
  final String? knownFor;

  factory PersonResult.fromJson(Map<String, dynamic> json) {
    return PersonResult(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      avatarUrl: tmdbImage(json['profilePath'] as String?),
      knownFor: json['knownForDepartment'] as String?,
    );
  }
}

class SearchState {
  const SearchState({
    this.query = '',
    this.tab = SearchTab.shows,
    this.showResults = const [],
    this.peopleResults = const [],
    this.isLoading = false,
    this.isGrid = true,
  });

  final String query;
  final SearchTab tab;
  final List<ShowResult> showResults;
  final List<PersonResult> peopleResults;
  final bool isLoading;
  final bool isGrid;

  SearchState copyWith({
    String? query,
    SearchTab? tab,
    List<ShowResult>? showResults,
    List<PersonResult>? peopleResults,
    bool? isLoading,
    bool? isGrid,
  }) =>
      SearchState(
        query: query ?? this.query,
        tab: tab ?? this.tab,
        showResults: showResults ?? this.showResults,
        peopleResults: peopleResults ?? this.peopleResults,
        isLoading: isLoading ?? this.isLoading,
        isGrid: isGrid ?? this.isGrid,
      );
}

// ── Provider ─────────────────────────────────────────────────────────

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref),
);

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState());
  final Ref _ref;

  void setQuery(String query) {
    state = state.copyWith(query: query, isLoading: query.isNotEmpty);
    _debounce(query);
  }

  DateTime? _lastSearch;
  Future<void> _debounce(String query) async {
    final now = DateTime.now();
    _lastSearch = now;
    await Future.delayed(const Duration(milliseconds: 350));
    if (_lastSearch != now) return;
    await _search(query);
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        showResults: [],
        peopleResults: [],
        isLoading: false,
      );
      return;
    }
    try {
      final api = _ref.read(apiClientProvider);
      final dynamic data = await api.get<dynamic>(
        '/shows/search',
        queryParameters: {'q': query},
      );

      final List rawList = data is List
          ? data
          : (data is Map && data['content'] is List ? data['content'] as List : []);

      final showResults = rawList
          .whereType<Map<String, dynamic>>()
          .map(ShowResult.fromJson)
          .toList();

      state = state.copyWith(
        showResults: showResults,
        peopleResults: const [],
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(showResults: [], isLoading: false);
    }
  }

  void setTab(SearchTab tab) => state = state.copyWith(tab: tab);

  void toggleLayout() => state = state.copyWith(isGrid: !state.isGrid);
}
