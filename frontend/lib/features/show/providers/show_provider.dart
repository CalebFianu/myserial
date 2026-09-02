import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/tmdb_image.dart';
import '../../lists/providers/lists_provider.dart';
import '../../profile/providers/profile_provider.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class SeasonSummary {
  const SeasonSummary({
    this.id = 0,
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.posterUrl,
    this.airDate,
    this.watchedCount = 0,
    this.avgRating,
  });

  final int id;
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? posterUrl;
  final String? airDate;
  final int watchedCount;
  final double? avgRating;

  factory SeasonSummary.fromJson(Map<String, dynamic> json) {
    return SeasonSummary(
      id: json['id'] as int? ?? 0,
      seasonNumber: json['seasonNumber'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      episodeCount: json['episodeCount'] as int? ?? 0,
      posterUrl: tmdbImage(json['posterPath'] as String?),
      airDate: json['airDate'] as String?,
      watchedCount: json['watchedCount'] as int? ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ??
          (json['voteAverage'] as num?)?.toDouble(),
    );
  }
}

class CastMember {
  const CastMember({
    required this.id,
    required this.personId,
    required this.name,
    required this.character,
    this.avatarUrl,
  });

  final int id;
  final int personId;
  final String name;
  final String character;
  final String? avatarUrl;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int? ?? 0,
      personId: json['personId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      character: json['characterName'] as String? ?? '',
      avatarUrl: tmdbImage(json['profilePath'] as String?),
    );
  }
}

class CrewMember {
  const CrewMember({
    required this.id,
    required this.name,
    required this.job,
    this.department,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String job;
  final String? department;
  final String? avatarUrl;

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      job: json['job'] as String? ?? '',
      department: json['department'] as String?,
      avatarUrl: tmdbImage(json['profilePath'] as String?),
    );
  }
}

class StreamingProvider {
  const StreamingProvider({
    required this.providerName,
    required this.providerType,
    this.logoUrl,
    this.leavingSoon,
    this.leavingDate,
  });

  final String providerName;
  final String providerType; // 'flatrate', 'rent', 'buy', 'free'
  final String? logoUrl;
  final bool? leavingSoon;
  final String? leavingDate;

  String get name => providerName;

  factory StreamingProvider.fromJson(Map<String, dynamic> json) {
    return StreamingProvider(
      providerName: json['providerName'] as String? ?? '',
      providerType: json['providerType'] as String? ?? 'flatrate',
      logoUrl: tmdbImage(json['logoPath'] as String?),
      leavingSoon: json['leavingSoon'] as bool?,
      leavingDate: json['leavingDate'] as String?,
    );
  }
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
    required this.totalEpisodes,
    required this.seasons,
    required this.cast,
    required this.crew,
    required this.streamingProviders,
    this.avgRating,
    this.rewatchCount = 0,
    this.isInWatchlist = false,
    this.watchedEpisodeCount = 0,
    this.isTracked = false,
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
  final bool isTracked;

  String get yearRange {
    if (firstAirYear == null) return '';
    if (lastAirYear == null || lastAirYear == firstAirYear) {
      return '$firstAirYear–';
    }
    return '$firstAirYear–$lastAirYear';
  }

  bool get hasWatched => watchedEpisodeCount > 0 || isTracked;

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
      isTracked: json['isTracked'] as bool? ?? false,
    );
  }
}

class EpisodeDetail {
  const EpisodeDetail({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    String? name,
    String? title,
    this.overview,
    this.stillUrl,
    this.runtime,
    this.airDate,
    bool isWatched = false,
    bool? watched,
    this.rating,
  })  : name = name ?? title ?? '',
        isWatched = watched ?? isWatched;

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? stillUrl;
  final int? runtime;
  final String? airDate;
  final bool isWatched;
  final double? rating;

  String get title => name;
  bool get watched => isWatched;

  factory EpisodeDetail.fromJson(Map<String, dynamic> json) {
    return EpisodeDetail(
      id: json['id'] as int? ?? 0,
      episodeNumber: json['episodeNumber'] as int? ?? 0,
      seasonNumber: json['seasonNumber'] as int? ?? 0,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      overview: json['overview'] as String?,
      stillUrl: tmdbImage(json['stillPath'] as String?),
      runtime: json['runtime'] as int?,
      airDate: json['airDate'] as String?,
      isWatched: json['isWatched'] as bool? ?? json['watched'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}

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

  factory RecapChapter.fromJson(Map<String, dynamic> json) {
    return RecapChapter(
      range: json['range'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      unlockAfterEpisode: json['unlockAfterEpisode'] as int? ?? 0,
    );
  }
}

class RecapData {
  const RecapData({
    required this.showTitle,
    required this.synopsis,
    required this.chapters,
    required this.watchedCount,
    required this.totalEpisodes,
  });

  final String showTitle;
  final String synopsis;
  final List<RecapChapter> chapters;
  final int watchedCount;
  final int totalEpisodes;

  factory RecapData.fromJson(Map<String, dynamic> json) {
    return RecapData(
      showTitle: json['showTitle'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      chapters: (json['chapters'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(RecapChapter.fromJson)
          .toList(),
      watchedCount: json['watchedCount'] as int? ?? 0,
      totalEpisodes: json['totalEpisodes'] as int? ?? 0,
    );
  }
}

class CastMemberFull {
  const CastMemberFull({
    required this.id,
    required this.name,
    required this.character,
    this.avatarUrl,
    required this.episodeCount,
  });

  final int id;
  final String name;
  final String character;
  final String? avatarUrl;
  final int episodeCount;

  factory CastMemberFull.fromJson(Map<String, dynamic> json) {
    return CastMemberFull(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      character: json['characterName'] as String? ?? '',
      avatarUrl: tmdbImage(json['profilePath'] as String?),
      episodeCount: json['episodeCount'] as int? ?? 0,
    );
  }
}

class CrewMemberFull {
  const CrewMemberFull({
    required this.id,
    required this.name,
    required this.department,
    required this.job,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String department;
  final String job;
  final String? avatarUrl;

  factory CrewMemberFull.fromJson(Map<String, dynamic> json) {
    return CrewMemberFull(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      job: json['job'] as String? ?? '',
      avatarUrl: tmdbImage(json['profilePath'] as String?),
    );
  }
}

class ShowCredits {
  const ShowCredits({required this.cast, required this.crew});
  final List<CastMemberFull> cast;
  final List<CrewMemberFull> crew;

  factory ShowCredits.fromJson(Map<String, dynamic> json) {
    return ShowCredits(
      cast: (json['cast'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CastMemberFull.fromJson)
          .toList(),
      crew: (json['crew'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CrewMemberFull.fromJson)
          .toList(),
    );
  }
}

class PersonCredit {
  const PersonCredit({
    required this.showId,
    required this.showTitle,
    this.character,
    this.job,
    this.posterUrl,
    this.year,
  });

  final int showId;
  final String showTitle;
  final String? character;
  final String? job;
  final String? posterUrl;
  final String? year;

  factory PersonCredit.fromJson(Map<String, dynamic> json) {
    return PersonCredit(
      showId: json['showId'] as int? ?? json['show']?['id'] as int? ?? 0,
      showTitle: json['showTitle'] as String? ?? json['show']?['title'] as String? ?? '',
      character: json['character'] as String? ?? json['characterName'] as String?,
      job: json['job'] as String?,
      posterUrl: tmdbImage(json['posterPath'] as String? ?? json['show']?['posterPath'] as String?),
      year: json['year'] as String?,
    );
  }
}

class PersonDetail {
  const PersonDetail({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.role,
    this.bio,
    this.credits = const [],
  });

  final int id;
  final String name;
  final String? avatarUrl;
  final String? role;
  final String? bio;
  final List<PersonCredit> credits;

  factory PersonDetail.fromJson(Map<String, dynamic> json) {
    return PersonDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatarUrl: tmdbImage(json['profilePath'] as String?),
      role: json['knownForDepartment'] as String?,
      bio: json['biography'] as String?,
      credits: (json['credits'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(PersonCredit.fromJson)
          .toList(),
    );
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

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
      isTracked: current.isTracked,
    ));

    try {
      if (newState) {
        await api.post('/lists/watchlist/${current.id}');
      } else {
        await api.delete('/lists/watchlist/${current.id}');
      }
      ref.invalidate(profileProvider);
      ref.invalidate(listsProvider);
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
        isTracked: current.isTracked,
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

final showRecapProvider =
    FutureProviderFamily<RecapData, ({int showId, int chunkSize})>(
  (ref, args) async {
    final api = ref.read(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>(
      '/shows/${args.showId}/recap',
      queryParameters: {'chunkSize': args.chunkSize},
    );
    return RecapData.fromJson(data);
  },
);

final recapProvider = FutureProviderFamily<RecapData, int>(
  (ref, showId) async {
    return ref.watch(showRecapProvider((showId: showId, chunkSize: 1)).future);
  },
);

final showCreditsProvider =
    FutureProviderFamily<ShowCredits, ({int showId, String? query})>(
  (ref, args) async {
    final api = ref.read(apiClientProvider);
    final queryParams = <String, dynamic>{};
    if (args.query != null && args.query!.isNotEmpty) {
      queryParams['q'] = args.query;
    }
    final data = await api.get<Map<String, dynamic>>(
      '/shows/${args.showId}/cast',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    return ShowCredits.fromJson(data);
  },
);

final personProvider = FutureProviderFamily<PersonDetail, int>(
  (ref, personId) async {
    final api = ref.read(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>('/people/$personId');
    return PersonDetail.fromJson(data);
  },
);
