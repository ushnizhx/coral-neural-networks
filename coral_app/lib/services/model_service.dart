import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class ModelService {
  // ────────────────────────────────────────────────────────────────────
  // HOW TO USE NGROK (for standalone / wireless use):
  //
  //  1. Install ngrok:  https://ngrok.com/download
  //  2. Start your FastAPI backend:
  //       uvicorn app:app --host 0.0.0.0 --port 8000
  //  3. In a NEW terminal, run:
  //       ngrok http 8000
  //  4. Ngrok will print a line like:
  //       Forwarding  https://abc123.ngrok-free.app -> http://localhost:8000
  //  5. Copy that https URL (e.g. https://abc123.ngrok-free.app)
  //     and paste it below as _ngrokUrl.
  //  6. Set _useNgrok = true, then rebuild the app:
  //       flutter build apk --release
  //
  // NOTE: The ngrok URL changes every time you restart ngrok (free plan).
  //       You must rebuild/reinstall the APK each time the URL changes.
  // ────────────────────────────────────────────────────────────────────

  /// Set to true to use ngrok (wireless/standalone mode).
  /// Set to false to use USB tunnel via `adb reverse` (USB-tethered mode).
  static const bool _useNgrok = true;

  /// Paste your ngrok forwarding URL here (no trailing slash).
  static const String _ngrokUrl = 'https://phantasmagorian-epagogic-chantal.ngrok-free.dev';

  /// USB tether mode: adb reverse maps phone's 127.0.0.1:8000 → PC port 8000.
  static const String _localUrl = 'http://127.0.0.1:8000';

  static String get _baseUrl => _useNgrok ? _ngrokUrl : _localUrl;

  static Future<AnalysisResult> analyzeImage(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);

    // Add ngrok bypass header (prevents ngrok's browser warning page)
    if (_useNgrok) {
      request.headers['ngrok-skip-browser-warning'] = 'true';
    }

    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AnalysisResult(
      predictedClass: json['predicted_class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: Map<String, double>.from(
        (json['probabilities'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      gradcamImage: base64Decode(json['gradcam_b64'] as String),
      heatmapImage: base64Decode(json['heatmap_b64'] as String),
    );
  }
}
