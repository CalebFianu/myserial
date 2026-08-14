import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

final _mockListDetail = {
  'l1': ListDetail(
    id: 'l1',
    name: 'Desert Island Picks',
    description: 'The shows I\'d take if stranded on a desert island with a TV and somehow WiFi.',
    shows: const [
      UserShow(id: 3, title: 'Succession', progress: 1.0, watchedEpisodes: 39, totalEpisodes: 39),
      UserShow(id: 4, title: 'The Wire', progress: 1.0, watchedEpisodes: 60, totalEpisodes: 60),
      UserShow(id: 1, title: 'Severance', progress: 0.63, watchedEpisodes: 12, totalEpisodes: 19),
    ],
    collaborators: [
      (name: 'Alex', avatarUrl: null),
    ],
  ),
  'l2': ListDetail(
    id: 'l2',
    name: 'Best Season Finales',
    description: 'Shows with the best season finale episodes.',
    shows: const [
      UserShow(id: 3, title: 'Succession', progress: 1.0, totalEpisodes: 39, watchedEpisodes: 39),
      UserShow(id: 2, title: 'The Bear', progress: 1.0, totalEpisodes: 20, watchedEpisodes: 20),
    ],
    collaborators: [],
  ),
  'l3': ListDetail(
    id: 'l3',
    name: 'Watch with Partner',
    description: 'Perfect for couch co-op binging.',
    shows: const [
      UserShow(id: 10, title: 'The Great', progress: 0.3, totalEpisodes: 30, watchedEpisodes: 9),
      UserShow(id: 11, title: 'Abbott Elementary', progress: 0.5, totalEpisodes: 60, watchedEpisodes: 30),
    ],
  ),
};

final listsProvider = FutureProvider<List<ListDetail>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockListDetail.values.toList();
});

final listDetailProvider =
    FutureProviderFamily<ListDetail?, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _mockListDetail[id];
});
