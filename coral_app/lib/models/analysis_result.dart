import 'dart:typed_data';

class AnalysisResult {
  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;
  final Uint8List gradcamImage;
  final Uint8List heatmapImage;

  AnalysisResult({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
    required this.gradcamImage,
    required this.heatmapImage,
  });
}
