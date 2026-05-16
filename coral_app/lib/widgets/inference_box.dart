import 'package:flutter/material.dart';
import '../theme.dart';

/// Returns the AI inference text based on the prediction class.
String _inferenceText(String predictionClass) {
  switch (predictionClass.toLowerCase()) {
    case 'healthy':
      return 'The model identifies strong pigmentation and intact coral structure, '
          'indicating a healthy coral ecosystem.';
    case 'bleached':
      return 'The model identifies pale, low-pigmentation regions consistent with '
          'coral bleaching, typically caused by environmental stress such as '
          'elevated sea temperatures.';
    case 'dead':
    default:
      return 'The model detects structural degradation and loss of living tissue, '
          'indicating dead or severely damaged coral.';
  }
}

/// A minimal, reusable inference explanation card.
///
/// Usage:
/// ```dart
/// InferenceBox(predictionClass: 'bleached')
/// ```
class InferenceBox extends StatelessWidget {
  final String predictionClass;

  const InferenceBox({super.key, required this.predictionClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14171C1F),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Teal curved accent bar ─────────────────────────────────
            _AccentBar(),

            // ── Content area ───────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C3A3C), // dark teal circle
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Inference text
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _inferenceText(predictionClass),
                          style: kBodyStyle.copyWith(
                            fontSize: 14,
                            height: 1.6,
                            color: const Color(0xFF4A5568), // muted gray
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The curved teal accent bar on the left edge.
class _AccentBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      child: CustomPaint(
        painter: _AccentBarPainter(),
      ),
    );
  }
}

class _AccentBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPrimaryTeal
      ..style = PaintingStyle.fill;

    // Rounded rect covering the full height, with rounded right edge only
    final path = Path();
    const radius = 8.0;
    path.moveTo(0, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
