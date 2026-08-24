const _base = 'https://image.tmdb.org/t/p';

String? tmdbImage(String? path, {String size = 'w500'}) {
  if (path == null || path.isEmpty) return null;
  final p = path.startsWith('/') ? path : '/$path';
  return '$_base/$size$p';
}
