import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({
    super.key,
    this.title,
    this.imageUrl,
    this.width,
    this.aspectRatio = 2 / 3,
    this.radius = AppRadius.poster,
    this.onTap,
  });

  final String? title;
  final String? imageUrl;
  final double? width;
  final double aspectRatio;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: SizedBox(
            width: width,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _Placeholder(title: title),
                    errorWidget: (_, __, ___) => _Placeholder(title: title),
                  )
                : _Placeholder(title: title),
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D2530),
            Color(0xFF141A21),
            Color(0xFF0C1014),
          ],
        ),
      ),
      child: title != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title!,
                    style: AppTypography.codeMicro.copyWith(
                      color: AppColors.fg2,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
