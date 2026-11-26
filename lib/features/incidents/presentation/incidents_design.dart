import 'package:flutter/material.dart';

import '../../../app/opervia_theme.dart';

class WhiteCard extends StatelessWidget {
  const WhiteCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
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
      borderRadius: BorderRadius.circular(12),
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
    this.background = OperviaColors.tint,
    this.foreground = OperviaColors.primary,
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
      backgroundColor: OperviaColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
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
    color: OperviaColors.amberBg,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: const Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: OperviaColors.amber),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'DATOS DE MUESTRA · Esta vista simula el reporte.',
            style: TextStyle(fontSize: 12, color: OperviaColors.navy),
          ),
        ),
      ],
    ),
  );
}
