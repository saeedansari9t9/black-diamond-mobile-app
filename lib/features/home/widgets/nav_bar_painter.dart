import 'package:flutter/material.dart';

class NavBarPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;

  NavBarPainter({required this.backgroundColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Path path = Path();

    // Starting point
    path.moveTo(0, 0);

    // Left side before notch
    double notchWidth = 70; // Width of the curve
    double center = size.width / 2;
    double curveStart = center - (notchWidth / 2) - 10;
    double curveEnd = center + (notchWidth / 2) + 10;

    path.lineTo(curveStart, 0);

    // The Notch Curve
    // First ease in
    path.quadraticBezierTo(
      center - (notchWidth / 2),
      0,
      center - (notchWidth / 2) + 5,
      15,
    );
    // The main dip
    path.arcToPoint(
      Offset(center + (notchWidth / 2) - 5, 15),
      radius: const Radius.circular(30),
      clockwise: false,
    );
    // Ease out
    path.quadraticBezierTo(center + (notchWidth / 2), 0, curveEnd, 0);

    // Right side
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.05), 4, true);

    // Draw background
    canvas.drawPath(path, paint);

    // Draw top border (only on the top edge including curve)
    // We recreate the top path for the border
    Path borderPath = Path();
    borderPath.moveTo(0, 0);
    borderPath.lineTo(curveStart, 0);
    borderPath.quadraticBezierTo(
      center - (notchWidth / 2),
      0,
      center - (notchWidth / 2) + 5,
      15,
    );
    borderPath.arcToPoint(
      Offset(center + (notchWidth / 2) - 5, 15),
      radius: const Radius.circular(30),
      clockwise: false,
    );
    borderPath.quadraticBezierTo(center + (notchWidth / 2), 0, curveEnd, 0);
    borderPath.lineTo(size.width, 0);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
