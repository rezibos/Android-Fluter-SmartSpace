import 'package:flutter/material.dart';

enum SpaceThemeMode { monochrome, orange }

class SpacePalette extends ThemeExtension<SpacePalette> {
  const SpacePalette({
    required this.background,
    required this.surface,
    required this.muted,
    required this.border,
    required this.ink,
    required this.inkMuted,
    required this.active,
    required this.onActive,
  });

  final Color background;
  final Color surface;
  final Color muted;
  final Color border;
  final Color ink;
  final Color inkMuted;
  final Color active;
  final Color onActive;

  static const danger = Color(0xFFE5484D);
  static const dangerBackground = Color(0xFFFDECEC);
  static const safe = Color(0xFF2FB36B);
  static const warning = Color(0xFFF2B01E);
  static const info = Color(0xFF3B82F6);

  @override
  SpacePalette copyWith({
    Color? background,
    Color? surface,
    Color? muted,
    Color? border,
    Color? ink,
    Color? inkMuted,
    Color? active,
    Color? onActive,
  }) => SpacePalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    muted: muted ?? this.muted,
    border: border ?? this.border,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    active: active ?? this.active,
    onActive: onActive ?? this.onActive,
  );

  @override
  SpacePalette lerp(covariant SpacePalette? other, double t) {
    if (other == null) return this;
    return SpacePalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      active: Color.lerp(active, other.active, t)!,
      onActive: Color.lerp(onActive, other.onActive, t)!,
    );
  }
}

class SpaceTheme {
  static const monochromePalette = SpacePalette(
    background: Color(0xFFF4F4F5),
    surface: Colors.white,
    muted: Color(0xFFEDEDEF),
    border: Color(0xFFE5E5E7),
    ink: Color(0xFF111111),
    inkMuted: Color(0xFF6B6B70),
    active: Color(0xFF111111),
    onActive: Colors.white,
  );

  static const orangePalette = SpacePalette(
    background: Color(0xFFF3F1EC),
    surface: Colors.white,
    muted: Color(0xFFE9E9E1),
    border: Color(0xFFDEDCD3),
    ink: Color(0xFF1B1B1B),
    inkMuted: Color(0xFF6F6F66),
    active: Color(0xFFFF6A1A),
    onActive: Colors.white,
  );

  static ThemeData build(SpaceThemeMode mode) {
    final palette = mode == SpaceThemeMode.orange
        ? orangePalette
        : monochromePalette;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.light(
        primary: palette.active,
        onPrimary: palette.onActive,
        surface: palette.surface,
        onSurface: palette.ink,
        error: SpacePalette.danger,
      ),
      fontFamily: 'sans-serif',
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: palette.ink,
        displayColor: palette.ink,
      ),
      extensions: [palette],
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.active,
        inactiveTrackColor: palette.muted,
        thumbColor: palette.active,
        trackHeight: 5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      ),
    );
  }
}

extension SpaceThemeContext on BuildContext {
  SpacePalette get space => Theme.of(this).extension<SpacePalette>()!;
}
