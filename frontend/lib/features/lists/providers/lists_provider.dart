import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/tmdb_image.dart';
import '../../../features/profile/providers/profile_provider.dart';

class ListDetail {
  const ListDetail({
    required this.id,
    required this.name,
    this.description,
    this.shows = const [],
    this.collaborators = const [],
    this.isWatchlist = false,
  });

  final String id;
  final String name;
  final String? description;
  final List<UserShow> shows;
  final List<({String name, String? avatarUrl})> collaborators;
  final bool isWatchlist;

  factory ListDetail.fromJson(Map<String, dynamic> json) {
    final shows = (json['shows'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((e) => UserShow(
              id: e['id'] as int? ?? 0,
              title: e['title'] as String? ?? '',
              posterUrl: tmdbImage(e['posterPath'] as String?),
              progress: 0.0,
              watchedEpisodes: 0,
              totalEpisodes: 0,
              status: e['status'] as String?,
            ))
        .toList();
    return ListDetail(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['note'] as String?,
      shows: shows,
      collaborators: const [],
      isWatchlist: json['isWatchlist'] as bool? ?? false,
    );
  }

  ListDetail copyWith({
    String? id,
    String? name,
    String? description,
    List<UserShow>? shows,
    List<({String name, String? avatarUrl})>? collaborators,
    bool? isWatchlist,
  }) {
    return ListDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shows: shows ?? this.shows,
      collaborators: collaborators ?? this.collaborators,
      isWatchlist: isWatchlist ?? this.isWatchlist,
    );
  }
}

// ── All lists notifier ───────────────────────────────────────────────────────

final listsProvider =
    AsyncNotifierProvider<ListsNotifier, List<ListDetail>>(ListsNotifier.new);

class ListsNotifier extends AsyncNotifier<List<ListDetail>> {
  @override
  Future<List<ListDetail>> build() async {
    final api = ref.read(apiClientProvider);
    final data = await api.get<List<dynamic>>('/lists');
    return data
        .cast<Map<String, dynamic>>()
        .map(ListDetail.fromJson)
        .toList();
  }

  Future<ListDetail> createList(String name, String? note) async {
    final api = ref.read(apiClientProvider);
    final data = await api.post<Map<String, dynamic>>(
      '/lists',
      data: {'name': name, if (note != null) 'note': note},
    );
    final created = ListDetail.fromJson(data);
    final current = state.valueOrNull ?? [];
    state = AsyncData([created, ...current]);
    ref.invalidate(profileProvider);
    return created;
  }

  Future<void> updateList(String listId, {String? name, String? note}) async {
    final api = ref.read(apiClientProvider);
    final data = await api.put<Map<String, dynamic>>(
      '/lists/$listId',
      data: {if (name != null) 'name': name, if (note != null) 'note': note},
    );
    final updated = ListDetail.fromJson(data);
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((l) => l.id == listId ? updated : l).toList(),
    );
    ref.invalidate(profileProvider);
  }

  Future<void> deleteList(String listId) async {
    final api = ref.read(apiClientProvider);
    final current = state.valueOrNull ?? [];

    // Optimistic removal
    state = AsyncData(current.where((l) => l.id != listId).toList());

    try {
      await api.delete('/lists/$listId');
      ref.invalidate(profileProvider);
    } catch (_) {
      // Revert
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> addItem(String listId, int showId) async {
    final api = ref.read(apiClientProvider);
    await api.post('/lists/$listId/items', data: {'showId': showId});
    ref.invalidateSelf();
    ref.invalidate(profileProvider);
  }

  Future<void> removeItem(String listId, int showId) async {
    final api = ref.read(apiClientProvider);
    final current = state.valueOrNull ?? [];

    // Optimistic removal
    state = AsyncData(
      current.map((l) {
        if (l.id != listId) return l;
        return l.copyWith(shows: l.shows.where((s) => s.id != showId).toList());
      }).toList(),
    );

    try {
      await api.delete('/lists/$listId/items/$showId');
      ref.invalidate(profileProvider);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

// ── Single list detail notifier ──────────────────────────────────────────────

final listDetailProvider = AsyncNotifierProviderFamily<ListDetailNotifier,
    ListDetail?, String>(ListDetailNotifier.new);

class ListDetailNotifier extends FamilyAsyncNotifier<ListDetail?, String> {
  @override
  Future<ListDetail?> build(String arg) async {
    final api = ref.read(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>('/lists/$arg');
    return ListDetail.fromJson(data);
  }

  Future<void> removeItem(int showId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final api = ref.read(apiClientProvider);

    // Optimistic
    state = AsyncData(
      current.copyWith(
        shows: current.shows.where((s) => s.id != showId).toList(),
      ),
    );

    try {
      await api.delete('/lists/${current.id}/items/$showId');
      // Also update the parent lists provider and profile
      ref.invalidate(listsProvider);
      ref.invalidate(profileProvider);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> addItem(int showId) async {
    final api = ref.read(apiClientProvider);
    final current = state.valueOrNull;
    if (current == null) return;

    await api.post('/lists/${current.id}/items', data: {'showId': showId});
    ref.invalidateSelf();
    ref.invalidate(listsProvider);
    ref.invalidate(profileProvider);
  }
}
