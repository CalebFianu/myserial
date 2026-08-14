import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'drift_database.g.dart';

// ── Tables ───────────────────────────────────────────────────────────────────

class LocalShows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tmdbId => integer().unique()();
  TextColumn get title => text()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get overview => text().nullable()();
  IntColumn get firstAirYear => integer().nullable()();
  IntColumn get lastAirYear => integer().nullable()();
  TextColumn get network => text().nullable()();
  IntColumn get totalEpisodes => integer().nullable()();
  RealColumn get avgRating => real().nullable()();
  DateTimeColumn get addedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class LocalSeasons extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get showId =>
      integer().references(LocalShows, #id, onDelete: KeyAction.cascade)();
  IntColumn get seasonNumber => integer()();
  TextColumn get name => text()();
  IntColumn get episodeCount => integer()();
  TextColumn get posterPath => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
}

class LocalEpisodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get showId =>
      integer().references(LocalShows, #id, onDelete: KeyAction.cascade)();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get name => text()();
  TextColumn get overview => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  IntColumn get runtime => integer().nullable()();
  TextColumn get stillPath => text().nullable()();
}

class LocalWatchedEpisodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId =>
      integer().references(LocalEpisodes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get watchedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

class LocalRatings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId =>
      integer().references(LocalEpisodes, #id, onDelete: KeyAction.cascade)();
  RealColumn get score => real()();
  TextColumn get review => text().nullable()();
  DateTimeColumn get ratedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

class LocalLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isWatchlist =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class LocalListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(LocalLists, #id, onDelete: KeyAction.cascade)();
  IntColumn get showId =>
      integer().references(LocalShows, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  LocalShows,
  LocalSeasons,
  LocalEpisodes,
  LocalWatchedEpisodes,
  LocalRatings,
  LocalLists,
  LocalListItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Handle migrations here
        },
      );

  // ── Shows ──────────────────────────────────────────────────────────────

  Future<List<LocalShow>> getAllShows() =>
      select(localShows).get();

  Future<LocalShow?> getShowByTmdbId(int tmdbId) =>
      (select(localShows)..where((t) => t.tmdbId.equals(tmdbId)))
          .getSingleOrNull();

  Future<int> upsertShow(LocalShowsCompanion show) =>
      into(localShows).insertOnConflictUpdate(show);

  // ── Episodes ──────────────────────────────────────────────────────────

  Future<List<LocalEpisode>> getEpisodesForShow(int showId) =>
      (select(localEpisodes)..where((t) => t.showId.equals(showId))).get();

  Future<List<LocalEpisode>> getEpisodesForSeason(
          int showId, int seasonNumber) =>
      (select(localEpisodes)
            ..where((t) =>
                t.showId.equals(showId) &
                t.seasonNumber.equals(seasonNumber))
            ..orderBy([(t) => OrderingTerm.asc(t.episodeNumber)]))
          .get();

  // ── Watched ───────────────────────────────────────────────────────────

  Future<List<LocalWatchedEpisode>> getWatchedForShow(int showId) =>
      (select(localWatchedEpisodes).join([
        innerJoin(
          localEpisodes,
          localEpisodes.id.equalsExp(localWatchedEpisodes.episodeId),
        ),
      ])
            ..where(localEpisodes.showId.equals(showId)))
          .map((r) => r.readTable(localWatchedEpisodes))
          .get();

  Future<bool> isEpisodeWatched(int episodeId) async {
    final row = await (select(localWatchedEpisodes)
          ..where((t) => t.episodeId.equals(episodeId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<int> markWatched(int episodeId) => into(localWatchedEpisodes)
      .insert(LocalWatchedEpisodesCompanion.insert(episodeId: episodeId));

  Future<int> markUnwatched(int episodeId) =>
      (delete(localWatchedEpisodes)
            ..where((t) => t.episodeId.equals(episodeId)))
          .go();

  // ── Ratings ───────────────────────────────────────────────────────────

  Future<LocalRating?> getRatingForEpisode(int episodeId) =>
      (select(localRatings)
            ..where((t) => t.episodeId.equals(episodeId)))
          .getSingleOrNull();

  Future<int> upsertRating(LocalRatingsCompanion rating) =>
      into(localRatings).insertOnConflictUpdate(rating);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'myserial.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
