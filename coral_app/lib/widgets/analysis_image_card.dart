import 'package:flutter/material.dart';
import '../theme.dart';

class AnalysisImageCard extends StatelessWidget {
  final Widget image;
  final String label;

  const AnalysisImageCard({
    super.key,
    required this.image,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardLowest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12), // xl = 0.75rem
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // shadow-sm roughly equivalent
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12), // p-3 = 0.75rem = 12px
      child: Column(
        children: [
          Container(
            height: 100, // h-36 is ~144, but prompt requests 100
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // lg = 8px
              color: kCardLowest,
            ),
            clipBehavior: Clip.antiAlias,
            child: image, // Intended to be an Image widget with fit:BoxFit.cover
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: kLabelStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: kTextSecondary,
            ),
          )
        ],
      ),
    );
  }
}
