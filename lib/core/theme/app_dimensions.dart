/// Design dimensions and spacing tokens for SpendSum.
class AppDimensions {
  AppDimensions._();

  // Spacing & Layout Rhythm
  static const double marginPage = 24.0;
  static const double gutterGrid = 16.0;
  static const double stackSm = 8.0;
  static const double stackMd = 16.0;
  static const double stackLg = 24.0;
  static const double stackXl = 40.0;

  // Border Radius (Mapped from rem to dp: 1rem = 16dp)
  static const double radiusSm = 8.0; // 0.5rem
  static const double radiusDefault = 16.0; // 1rem
  static const double radiusMd = 24.0; // 1.5rem
  static const double radiusLg = 32.0; // 2rem
  static const double radiusXl = 48.0; // 3rem
  static const double radiusFull = 9999.0;

  // Widget-specific radius
  static const double radiusIcon = 12.0; // icon container corner radius
  static const double radiusPill = 22.0; // pill-shaped toggle/tab radius

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 28.0;
  static const double iconNavSize = 22.0; // bottom-nav icon size

  // Avatar & touch target sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 42.0;
  static const double avatarLg = 56.0;

  // Tile & card internal spacing
  static const double tileVerticalPad = 12.0;
  static const double tileHorizontalPad = 14.0;
  static const double cardPadSm = 12.0;
  static const double cardPadMd = 16.0;
  static const double cardPadLg = 20.0;
  static const double iconContainerPad = 10.0; // padding inside circular icon containers

  // Elevation reference
  static const double elevationNone = 0.0;
  static const double elevationCard = 2.0;

  // Component-specific dimensions
  static const double tabHeight = 44.0; // height of toggle tab / pill button
}
