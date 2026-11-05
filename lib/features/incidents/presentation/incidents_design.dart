import 'package:flutter/material.dart';

/// Colores aproximados tomados del Figma (US07). Ajustar con los tokens reales.
abstract final class FigmaColors {
  static const primary = Color(0xFF1D6FEA);
  static const navy = Color(0xFF0B1F4B);
  static const muted = Color(0xFF5B6B86);
  static const tint = Color(0xFFE4EEFC);
  static const greenBg = Color(0xFFDDF4E8);
  static const green = Color(0xFF1FA971);
  static const amberBg = Color(0xFFFFF1D6);
  static const amber = Color(0xFFE59A00);
  static const error = Color(0xFFE5484D);
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBFDDFB), Color(0xFFF4F9FF), Colors.white],
        stops: [0, 0.45, 1],
      ),
    ),
    child: child,
  );
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.borderColor,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final Color color;
  final Color? borderColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      border: borderColor == null
          ? null
          : Border.all(color: borderColor!, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class IconSquare extends StatelessWidget {
  const IconSquare({
    super.key,
    required this.icon,
    this.background = FigmaColors.tint,
    this.foreground = FigmaColors.primary,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: foreground, size: 22),
  );
}

/// Encabezado de las pantallas internas: volver, título, campana y avatar.
class FigmaHeader extends StatelessWidget {
  const FigmaHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: FigmaColors.navy,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: FigmaColors.navy,
            ),
          ),
        ),
        const _BellAndAvatar(),
      ],
    ),
  );
}

class _BellAndAvatar extends StatelessWidget {
  const _BellAndAvatar();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Stack(
        children: [
          const Icon(Icons.notifications_none, color: FigmaColors.navy),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: FigmaColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 12),
      const CircleAvatar(
        radius: 18,
        backgroundColor: FigmaColors.tint,
        child: Icon(Icons.person, color: FigmaColors.primary),
      ),
    ],
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: loading ? null : onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: FigmaColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(icon, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

/// Rótulo visible mientras los datos no vengan del backend.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: FigmaColors.amberBg,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: const Row(
      children: [
        Icon(Icons.science_outlined, size: 18, color: FigmaColors.amber),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'DATOS DE MUESTRA · Sin conexión con el backend '
            '(aún no existe el contrato de incidencias).',
            style: TextStyle(fontSize: 12, color: FigmaColors.navy),
          ),
        ),
      ],
    ),
  );
}
