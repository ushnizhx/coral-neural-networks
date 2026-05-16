import 'dart:io';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/analysis_result.dart';
import '../widgets/probability_bar.dart';
import '../widgets/analysis_image_card.dart';
import '../widgets/inference_box.dart';

class ResultsScreen extends StatelessWidget {
  final AnalysisResult result;
  final File imageFile;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryContainer), // #007B83
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Coral Neural Networks',
          style: kHeadlineStyle.copyWith(
            fontSize: 18,
            color: kPrimaryContainer,
          ),
        ),
        backgroundColor: kCardLowest.withOpacity(0.4),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // px-6 pb-12 equivalent to roughly 24
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Original Image
            Container(
              decoration: BoxDecoration(
                color: kCardLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F171C1F), // 6% shadow approx
                    offset: Offset(0, 20),
                    blurRadius: 40,
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200, // aspect-video is ~ 16:9, close to 200 depending on screen width
              ),
            ),
            const SizedBox(height: 32),

            // Primary Diagnosis Card
            Container(
              padding: const EdgeInsets.all(32), // p-8
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryTeal, kPrimaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRIMARY DIAGNOSIS',
                    style: kLabelStyle.copyWith(
                      color: kOnPrimary.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.predictedClass[0].toUpperCase()}${result.predictedClass.substring(1)} Coral',
                    style: kHeadlineStyle.copyWith(
                      color: kOnPrimary,
                      fontSize: 36, // text-4xl
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(result.confidence * 100).round()}% confidence',
                    style: kBodyStyle.copyWith(
                      color: kOnPrimary.withOpacity(0.9),
                      fontSize: 18, // text-lg
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Probability Spectrum
            Text(
              'Probability Spectrum',
              style: kHeadlineStyle.copyWith(
                fontSize: 18,
                color: kTextSecondary, // on-surface-variant
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24), // p-6
              decoration: BoxDecoration(
                color: kCardLowest.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ProbabilityBar(
                    label: 'Healthy',
                    probability: result.probabilities['healthy'] ?? 0,
                    barColor: kSecondary,
                  ),
                  const SizedBox(height: 24), // space-y-6
                  ProbabilityBar(
                    label: 'Bleached',
                    probability: result.probabilities['bleached'] ?? 0,
                    barColor: kBleachedAmber,
                  ),
                  const SizedBox(height: 24),
                  ProbabilityBar(
                    label: 'At Risk / Dead',
                    probability: result.probabilities['dead'] ?? 0,
                    barColor: kDeadRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Analysis Results
            Text(
              'Analysis Results',
              style: kHeadlineStyle.copyWith(
                fontSize: 18,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Row of analysis cards
            Row(
              children: [
                Expanded(
                  child: AnalysisImageCard(
                    image: Image.file(imageFile, fit: BoxFit.cover),
                    label: 'Original',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalysisImageCard(
                    image: Image.memory(result.gradcamImage, fit: BoxFit.cover),
                    label: 'Grad-CAM',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalysisImageCard(
                    image: Image.memory(result.heatmapImage, fit: BoxFit.cover),
                    label: 'Heatmap',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCardLowest.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 16, color: kTextPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Highlighted regions indicate areas the model used for classification.',
                      style: kBodyStyle.copyWith(
                        fontSize: 12,
                        color: kTextPrimary,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Inference Box
            InferenceBox(predictionClass: result.predictedClass),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
