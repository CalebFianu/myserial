import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/tmdb_image.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.avatarUrl,
    this.order = 0,
  });
  final int id;
  final String name;
  final String character;
  final String? avatarUrl;
  final int order;

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        character: json['characterName'] as String? ?? '',
        avatarUrl: tmdbImage(json['profilePath'] as String?, size: 'w185'),
        order: json['displayOrder'] as int? ?? 0,
      );
}

class CrewMember {
  const CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.avatarUrl,
  });
  final int id;
  final String name;
  final String job;
  final String department;
  final String? avatarUrl;

  factory CrewMember.fromJson(Map<String, dynamic> json) => CrewMember(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        job: json['job'] as String? ?? '',
        department: json['department'] as String? ?? '',
        avatarUrl: tmdbImage(json['profilePath'] as String?, size: 'w185'),
      );
}

class SeasonSummary {
  const SeasonSummary({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.posterUrl,
    this.avgRating,
    this.watchedCount = 0,
  });
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? posterUrl;
  final double? avgRating;
  final int watchedCount;

  factory SeasonSummary.fromJson(Map<String, dynamic> json) => SeasonSummary(
        seasonNumber: json['seasonNumber'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        episodeCount: json['episodeCount'] as int? ?? 0,
        posterUrl: tmdbImage(json['posterPath'] as String?),
        avgRating: null,
        watchedCount: 0,
      );
}

class StreamingProvider {
  const StreamingProvider({
    required this.name,
    this.logoUrl,
    this.leavingSoon,
    this.leavingDate,
  });
  final String name;
  final String? logoUrl;
  final bool? leavingSoon;
  final String? leavingDate;

  factory StreamingProvider.fromJson(Map<String, dynamic> json) =>
      StreamingProvider(
        name: json['providerName'] as String? ?? '',
        logoUrl: tmdbImage(json['providerLogoPath'] as String?),
        leavingSoon: null,
        leavingDate: null,
      );
}

class ShowDetail {
  const ShowDetail({
    required this.id,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    this.status,
    this.firstAirYear,
    this.lastAirYear,
    this.network,
    this.totalEpisodes,
    this.seasons = const [],
    this.cast = const [],
    this.crew = const [],
    this.streamingProviders = const [],
    this.avgRating,
    this.rewatchCount = 0,
    this.isInWatchlist = false,
    this.watchedEpisodeCount = 0,
  });

  final int id;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final String? status;
  final int? firstAirYear;
  final int? lastAirYear;
  final String? network;
  final int? totalEpisodes;
  final List<SeasonSummary> seasons;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final List<StreamingProvider> streamingProviders;
  final double? avgRating;
  final int rewatchCount;
  final bool isInWatchlist;
  final int watchedEpisodeCount;

  String get yearRange {
    if (firstAirYear == null) return '';
    if (lastAirYear == null || lastAirYear == firstAirYear) {
      return '$firstAirYear–';
    }
    return '$firstAirYear–$lastAirYear';
  }

  bool get hasWatched => watchedEpisodeCount > 0;

  factory ShowDetail.fromJson(Map<String, dynamic> json) {
    final seasons = (json['seasons'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(SeasonSummary.fromJson)
        .toList();
    final totalEpisodes =
        seasons.fold<int>(0, (sum, s) => sum + s.episodeCount);

    int? parseYear(String? dateStr) {
      if (dateStr == null || dateStr.length < 4) return null;
      return int.tryParse(dateStr.substring(0, 4));
    }

    return ShowDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      posterUrl: tmdbImage(json['posterPath'] as String?),
      backdropUrl: tmdbImage(json['backdropPath'] as String?, size: 'original'),
      overview: json['overview'] as String?,
      status: json['status'] as String?,
      firstAirYear: parseYear(json['firstAirDate'] as String?),
      lastAirYear: parseYear(json['lastAirDate'] as String?),
      network: json['network'] as String?,
      totalEpisodes: totalEpisodes,
      seasons: seasons,
      cast: (json['castPreview'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CastMember.fromJson)
          .toList(),
      crew: (json['crewPreview'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CrewMember.fromJson)
          .toList(),
      streamingProviders: (json['streamingAvailability'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(StreamingProvider.fromJson)
          .toList(),
      avgRating: (json['voteAverage'] as num?)?.toDouble(),
      rewatchCount: 0,
      isInWatchlist: json['isInWatchlist'] as bool? ?? false,
      watchedEpisodeCount: json['watchedEpisodeCount'] as int? ?? 0,
    );
  }
}

class EpisodeDetail {
  const EpisodeDetail({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.airDate,
    this.runtime,
    this.stillUrl,
    this.watched = false,
    this.rating,
  });

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? airDate;
  final int? runtime;
  final String? stillUrl;
  final bool watched;
  final double? rating;

  factory EpisodeDetail.fromJson(Map<String, dynamic> json) => EpisodeDetail(
        id: json['id'] as int? ?? 0,
        episodeNumber: json['episodeNumber'] as int? ?? 0,
        seasonNumber: json['seasonNumber'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        overview: json['overview'] as String?,
        airDate: json['airDate'] as String?,
        runtime: json['runtime'] as int?,
        stillUrl: tmdbImage(json['stillPath'] as String?, size: 'w300'),
        watched: false,
        rating: null,
      );
}

// ── Person models ─────────────────────────────────────────────────────────────

class PersonCredit {
  const PersonCredit({
    required this.showId,
    required this.showTitle,
    this.posterUrl,
    this.character,
  });
  final int showId;
  final String showTitle;
  final String? posterUrl;
  final String? character;
}

class PersonData {
  const PersonData({
    required this.id,
    required this.name,
    this.role,
    this.bio,
    this.avatarUrl,
    this.credits = const [],
  });
  final int id;
  final String name;
  final String? role;
  final String? bio;
  final String? avatarUrl;
  final List<PersonCredit> credits;

  factory PersonData.fromJson(Map<String, dynamic> json) {
    final knownFor = (json['knownFor'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((e) => PersonCredit(
              showId: e['id'] as int? ?? 0,
              showTitle: e['title'] as String? ?? '',
              posterUrl: tmdbImage(e['posterPath'] as String?),
              character: null,
            ))
        .toList();
    return PersonData(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      role: json['knownForDepartment'] as String?,
      bio: json['biography'] as String?,
      avatarUrl: tmdbImage(json['profilePath'] as String?, size: 'w185'),
      credits: knownFor,
    );
  }
}

// ── Recap models ──────────────────────────────────────────────────────────────

class RecapChapter {
  const RecapChapter({
    required this.range,
    required this.title,
    required this.body,
    required this.unlockAfterEpisode,
  });
  final String range;
  final String title;
  final String body;
  final int unlockAfterEpisode;

  factory RecapChapter.fromJson(Map<String, dynamic> json) => RecapChapter(
        range: json['range'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        unlockAfterEpisode: json['unlockAfterEpisode'] as int? ?? 0,
      );
}

class RecapData {
  const RecapData({
    required this.chapters,
    required this.watchedCount,
  });
  final List<RecapChapter> chapters;
  final int watchedCount;

  factory RecapData.fromJson(Map<String, dynamic> json) => RecapData(
        chapters: (json['chapters'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(RecapChapter.fromJson)
            .toList(),
        watchedCount: json['watchedCount'] as int? ?? 0,
      );
}

// ── Providers ─────────────────────────────────────────────────────────────────

final showDetailProvider =
    AsyncNotifierProviderFamily<ShowDetailNotifier, ShowDetail, int>(
  ShowDetailNotifier.new,
);

class ShowDetailNotifier extends FamilyAsyncNotifier<ShowDetail, int> {
  @override
  Future<ShowDetail> build(int arg) async {
    final api = ref.watch(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>('/shows/$arg');
    return ShowDetail.fromJson(data);
  }

  Future<void> toggleWatchlist() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final api = ref.read(apiClientProvider);
    final newState = !current.isInWatchlist;

    // Optimistic update
    state = AsyncData(ShowDetail(
      id: current.id,
      title: current.title,
      posterUrl: current.posterUrl,
      backdropUrl: current.backdropUrl,
      overview: current.overview,
      status: current.status,
      firstAirYear: current.firstAirYear,
      lastAirYear: current.lastAirYear,
      network: current.network,
      totalEpisodes: current.totalEpisodes,
      seasons: current.seasons,
      cast: current.cast,
      crew: current.crew,
      streamingProviders: current.streamingProviders,
      avgRating: current.avgRating,
      rewatchCount: current.rewatchCount,
      isInWatchlist: newState,
      watchedEpisodeCount: current.watchedEpisodeCount,
    ));

    try {
      if (newState) {
        await api.post('/lists/watchlist/${current.id}');
      } else {
        await api.delete('/lists/watchlist/${current.id}');
      }
    } catch (_) {
      // Revert on failure
      state = AsyncData(ShowDetail(
        id: current.id,
        title: current.title,
        posterUrl: current.posterUrl,
        backdropUrl: current.backdropUrl,
        overview: current.overview,
        status: current.status,
        firstAirYear: current.firstAirYear,
        lastAirYear: current.lastAirYear,
        network: current.network,
        totalEpisodes: current.totalEpisodes,
        seasons: current.seasons,
        cast: current.cast,
        crew: current.crew,
        streamingProviders: current.streamingProviders,
        avgRating: current.avgRating,
        rewatchCount: current.rewatchCount,
        isInWatchlist: current.isInWatchlist,
        watchedEpisodeCount: current.watchedEpisodeCount,
      ));
    }
  }
}

final seasonEpisodesProvider =
    FutureProviderFamily<List<EpisodeDetail>, ({int showId, int seasonNumber})>(
  (ref, args) async {
    final api = ref.read(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>(
        '/shows/${args.showId}/seasons/${args.seasonNumber}');
    final episodes = data['episodes'] as List? ?? [];
    return episodes
        .cast<Map<String, dynamic>>()
        .map(EpisodeDetail.fromJson)
        .toList();
  },
);

final personProvider =
    FutureProviderFamily<PersonData, int>((ref, personId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get<Map<String, dynamic>>('/people/$personId');
  return PersonData.fromJson(data);
});

final recapProvider =
    FutureProviderFamily<RecapData, int>((ref, showId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get<Map<String, dynamic>>('/shows/$showId/recap');
  return RecapData.fromJson(data);
});
