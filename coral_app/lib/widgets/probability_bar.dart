import 'package:flutter/material.dart';
import '../theme.dart';

class ProbabilityBar extends StatelessWidget {
  final String label;
  final double probability;
  final Color barColor;

  const ProbabilityBar({
    super.key,
    required this.label,
    required this.probability,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: kLabelStyle.copyWith(
                fontSize: 12,
                color: barColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(probability * 100).toStringAsFixed(1)}%',
              style: kBodyStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: kCardHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: probability),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
