import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

/// A circular avatar widget using CachedNetworkImage with a text fallback placeholder.
class NetworkAvatar extends StatelessWidget {
  final String imageUrl;
  final String initials;
  final Color backgroundColor;

  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 40.0,
        height: 40.0,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      width: 40.0,
      height: 40.0,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: themeExt.onSurface,
        ),
      ),
    );
  }
}
