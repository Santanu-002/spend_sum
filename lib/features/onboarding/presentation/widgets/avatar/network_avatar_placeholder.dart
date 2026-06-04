part of 'network_avatar.dart';

class _NetworkAvatarPlaceholder extends StatelessWidget {
  final String initials;
  final Color backgroundColor;

  const _NetworkAvatarPlaceholder({
    required this.initials,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
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
