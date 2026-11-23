import 'package:flutter/material.dart';

abstract final class OperviaColors {
  static const primary = Color(0xFF086DDF);
  static const navy = Color(0xFF07133F);
  static const muted = Color(0xFF526274);
  static const tint = Color(0xFFE5F2FC);
  static const line = Color(0xFFCFDCE6);
  static const greenBg = Color(0xFFD8F3EE);
  static const green = Color(0xFF08786A);
  static const amberBg = Color(0xFFFFF1D6);
  static const amber = Color(0xFF895507);
  static const error = Color(0xFFB32635);
}

ThemeData operviaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'IBM Plex Sans',
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: OperviaColors.primary,
      onPrimary: Colors.white,
      primaryContainer: OperviaColors.tint,
      onPrimaryContainer: OperviaColors.navy,
      secondary: OperviaColors.green,
      secondaryContainer: OperviaColors.greenBg,
      onSecondaryContainer: OperviaColors.navy,
      tertiaryContainer: OperviaColors.amberBg,
      onTertiaryContainer: OperviaColors.amber,
      surface: Colors.white,
      onSurface: OperviaColors.navy,
      onSurfaceVariant: OperviaColors.muted,
      outline: OperviaColors.muted,
      outlineVariant: OperviaColors.line,
      error: OperviaColors.error,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.4),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: OperviaColors.navy,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: OperviaColors.navy.withValues(alpha: .15),
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: OperviaColors.tint,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? OperviaColors.primary
              : OperviaColors.muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => base.textTheme.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected)
              ? OperviaColors.primary
              : OperviaColors.muted,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        visualDensity: VisualDensity.standard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

class OperviaContent extends StatelessWidget {
  const OperviaContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: child,
    ),
  );
}
