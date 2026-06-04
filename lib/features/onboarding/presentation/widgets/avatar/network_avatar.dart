import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

part 'network_avatar_placeholder.dart';

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
        placeholder: (context, url) => _NetworkAvatarPlaceholder(
          initials: initials,
          backgroundColor: backgroundColor,
        ),
        errorWidget: (context, url, error) => _NetworkAvatarPlaceholder(
          initials: initials,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

