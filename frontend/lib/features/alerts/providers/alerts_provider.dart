import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AlertItem {
  const AlertItem({
    required this.id,
    this.showId,
    this.showTitle,
    required this.title,
    this.body,
    required this.createdAt,
    required this.isRead,
  });

  final int id;
  final int? showId;
  final String? showTitle;
  final String title;
  final String? body;
  final DateTime createdAt;
  final bool isRead;

  factory AlertItem.fromJson(Map<String, dynamic> json) => AlertItem(
        id: json['id'] as int,
        showId: json['showId'] as int?,
        showTitle: json['showTitle'] as String?,
        title: json['title'] as String? ?? '',
        body: json['body'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['readAt'] != null,
      );

  AlertItem copyWith({bool? isRead}) => AlertItem(
        id: id,
        showId: showId,
        showTitle: showTitle,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );
}

// ── Provider ──────────────────────────────────────────────────────────────────

final alertsProvider =
    AsyncNotifierProvider<AlertsNotifier, List<AlertItem>>(AlertsNotifier.new);

class AlertsNotifier extends AsyncNotifier<List<AlertItem>> {
  @override
  Future<List<AlertItem>> build() async {
    final api = ref.watch(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>('/alerts?size=50');
    final content = data['content'] as List? ?? [];
    return content
        .map((e) => AlertItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(int id) async {
    // Optimistic update
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current
          .map((a) => a.id == id ? a.copyWith(isRead: true) : a)
          .toList());
    }
    try {
      final api = ref.read(apiClientProvider);
      await api.post<void>('/alerts/$id/read');
    } catch (_) {
      // Revert on error by refreshing
      ref.invalidateSelf();
    }
  }
}
