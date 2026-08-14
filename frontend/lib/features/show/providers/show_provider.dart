import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

// ── Mock data ─────────────────────────────────────────────────────────────────

ShowDetail _mockShowDetail(int id) => ShowDetail(
      id: id,
      title: 'Severance',
      overview:
          'Mark leads a team of office workers whose memories have been surgically divided between their work and personal lives. When a mysterious colleague appears outside of work, it begins a journey to discover the truth about their jobs.',
      status: 'Returning',
      firstAirYear: 2022,
      network: 'Apple TV+',
      totalEpisodes: 19,
      watchedEpisodeCount: 6,
      isInWatchlist: false,
      avgRating: 4.5,
      rewatchCount: 0,
      streamingProviders: const [
        StreamingProvider(
          name: 'Apple TV+',
          leavingSoon: false,
        ),
      ],
      seasons: const [
        SeasonSummary(
          seasonNumber: 1,
          name: 'Season 1',
          episodeCount: 9,
          avgRating: 4.6,
          watchedCount: 9,
        ),
        SeasonSummary(
          seasonNumber: 2,
          name: 'Season 2',
          episodeCount: 10,
          avgRating: 4.4,
          watchedCount: 3,
        ),
      ],
      cast: const [
        CastMember(id: 1, name: 'Adam Scott', character: 'Mark S.', order: 0),
        CastMember(id: 2, name: 'Zach Cherry', character: 'Dylan G.', order: 1),
        CastMember(id: 3, name: 'Britt Lower', character: 'Helly R.', order: 2),
        CastMember(id: 4, name: 'Tramell Tillman', character: 'Milchick', order: 3),
        CastMember(id: 5, name: 'Jen Tullock', character: 'Devon', order: 4),
        CastMember(id: 6, name: 'Dichen Lachman', character: 'Ms. Casey', order: 5),
      ],
      crew: const [
        CrewMember(id: 100, name: 'Dan Erickson', job: 'Creator', department: 'Writing'),
        CrewMember(id: 101, name: 'Ben Stiller', job: 'Director', department: 'Directing'),
        CrewMember(id: 102, name: 'Aoife McArdle', job: 'Director', department: 'Directing'),
      ],
    );

List<EpisodeDetail> _mockEpisodes(int showId, int seasonNumber) =>
    List.generate(seasonNumber == 1 ? 9 : 10, (i) {
      final ep = i + 1;
      return EpisodeDetail(
        id: showId * 1000 + seasonNumber * 100 + ep,
        episodeNumber: ep,
        seasonNumber: seasonNumber,
        name: [
          'Good News About Hell',
          'Half Loop',
          'In Perpetuity',
          'The You You Are',
          'The Grim Barbarity of Optics and Design',
          'Hide and Seek',
          'Defiant Jazz',
          'What\'s for Dinner?',
          'The We We Are',
          'Woe\'s Hollow',
        ][i % 10],
        overview: 'Episode $ep of Season $seasonNumber.',
        airDate: '2022-02-${(i + 18).toString().padLeft(2, '0')}',
        runtime: 42 + (i % 3) * 5,
        watched: seasonNumber == 1 || (seasonNumber == 2 && ep <= 3),
        rating: (seasonNumber == 1 || ep <= 2) ? 4.0 + (i % 5) * 0.2 : null,
      );
    });

// ── Providers ─────────────────────────────────────────────────────────────────

final showDetailProvider =
    AsyncNotifierProviderFamily<ShowDetailNotifier, ShowDetail, int>(
  ShowDetailNotifier.new,
);

class ShowDetailNotifier
    extends FamilyAsyncNotifier<ShowDetail, int> {
  @override
  Future<ShowDetail> build(int arg) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockShowDetail(arg);
  }

  Future<void> toggleWatchlist() async {
    final current = state.valueOrNull;
    if (current == null) return;
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
      isInWatchlist: !current.isInWatchlist,
      watchedEpisodeCount: current.watchedEpisodeCount,
    ));
  }
}

final seasonEpisodesProvider = FutureProviderFamily<List<EpisodeDetail>, ({int showId, int seasonNumber})>(
  (ref, args) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockEpisodes(args.showId, args.seasonNumber);
  },
);
