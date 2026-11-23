import 'package:flutter/material.dart';

class OperviaBackdrop extends StatelessWidget {
  const OperviaBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topSpacing = MediaQuery.sizeOf(context).height < 480 ? 16.0 : 40.0;
    return CustomPaint(
      painter: const _BackdropPainter(),
      child: Padding(
        padding: EdgeInsets.only(top: topSpacing),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final width = size.width;
    final height = size.height;

    // Match the shared Opervia backdrop in the Android app.
    const base = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFDDF3FF), Color(0xFFF4FAFE), Color(0xFFF5FCFC)],
    );
    canvas.drawRect(bounds, Paint()..shader = base.createShader(bounds));

    final header = Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height * .08)
      ..quadraticBezierTo(width * .3, height * .2, 0, height * .045)
      ..close();
    const headerGradient = LinearGradient(
      colors: [Color(0xFF89CEFA), Color(0xFFDEF3FF)],
    );
    canvas.drawPath(
      header,
      Paint()..shader = headerGradient.createShader(bounds),
    );

    final diagonal = Path()
      ..moveTo(width * .35, 0)
      ..lineTo(width, height * .3)
      ..lineTo(width, height * .13)
      ..lineTo(width * .65, 0)
      ..close();
    canvas.drawPath(diagonal, Paint()..color = const Color(0x479AD7FA));

    final lower = Path()
      ..moveTo(0, height * .42)
      ..lineTo(width, height * .18)
      ..lineTo(width, height * .3)
      ..lineTo(0, height * .54)
      ..close();
    canvas.drawPath(lower, Paint()..color = const Color(0x42FFFFFF));
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) => false;
}
