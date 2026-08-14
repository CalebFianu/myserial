import 'package:flutter/material.dart';
import '../../design/spacing.dart';
import 'poster_placeholder.dart';

class PosterRailItem {
  const PosterRailItem({
    required this.title,
    this.imageUrl,
    this.onTap,
    this.subtitle,
  });

  final String title;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? subtitle;
}

class PosterRail extends StatelessWidget {
  const PosterRail({
    super.key,
    required this.items,
    this.posterWidth = 100,
    this.height,
    this.padding,
  });

  final List<PosterRailItem> items;
  final double posterWidth;
  final double? height;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? posterWidth / (2 / 3),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.railGap),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: posterWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PosterPlaceholder(
                    title: item.title,
                    imageUrl: item.imageUrl,
                    width: posterWidth,
                    onTap: item.onTap,
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle!,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
