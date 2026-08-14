import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/typography.dart';

class MsAvatar extends StatelessWidget {
  const MsAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 40,
    this.ringColor,
    this.ringWidth = 2,
    this.onTap,
  });

  final String? name;
  final String? imageUrl;
  final double size;
  final Color? ringColor;
  final double ringWidth;
  final VoidCallback? onTap;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  Color _colorFromName(String? n) {
    if (n == null) return AppColors.ink2;
    final colors = [
      const Color(0xFF4C6EF5),
      const Color(0xFF7950F2),
      const Color(0xFFE64980),
      AppColors.signal,
      AppColors.track,
      AppColors.star,
      const Color(0xFF0CA678),
      const Color(0xFF1C7ED6),
    ];
    final idx = n.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _InitialsFallback(
          initials: _initials,
          color: _colorFromName(name),
          size: size,
        ),
        errorWidget: (_, __, ___) => _InitialsFallback(
          initials: _initials,
          color: _colorFromName(name),
          size: size,
        ),
      );
    } else {
      avatar = _InitialsFallback(
        initials: _initials,
        color: _colorFromName(name),
        size: size,
      );
    }

    Widget result = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ringColor != null
            ? Border.all(color: ringColor!, width: ringWidth)
            : null,
      ),
      child: avatar,
    );

    if (onTap != null) {
      result = GestureDetector(onTap: onTap, child: result);
    }

    return result;
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({
    required this.initials,
    required this.color,
    required this.size,
  });

  final String initials;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.microSemiBold.copyWith(
          color: color,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}
