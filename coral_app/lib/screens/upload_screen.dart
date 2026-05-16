import 'dart:io';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/upload_zone.dart';
import '../services/model_service.dart';
import 'results_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await ModelService.analyzeImage(_selectedImage!);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            result: result,
            imageFile: _selectedImage!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not reach analysis server: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Coral Neural Networks',
          style: kHeadlineStyle.copyWith(fontSize: 18, color: kTextPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ──────────────────────────────────────────
          Image.asset(
            'assets/bg_coral.png',
            fit: BoxFit.cover,
          ),
          // Light overlay so text stays readable
          Container(color: Colors.white.withValues(alpha: 0.45)),

          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kSecondaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'NEW ANALYSIS',
                      style: kLabelStyle.copyWith(
                        fontSize: 12,
                        color: kSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Headline
                  RichText(
                    text: TextSpan(
                      style: kHeadlineStyle.copyWith(fontSize: 32, height: 1.25),
                      children: const [
                        TextSpan(text: 'Upload a photo of coral to begin\n'),
                        TextSpan(
                          text: 'analysis',
                          style: TextStyle(color: kPrimaryTeal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Upload zone
                  UploadZone(
                    selectedImage: _selectedImage,
                    onImageSelected: (file) {
                      setState(() => _selectedImage = file);
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Buttons (stacked to avoid overflow) ───────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Analyze button (always shown, disabled when no image)
                      ElevatedButton.icon(
                        onPressed: _selectedImage == null ? null : _analyzeImage,
                        icon: const Icon(Icons.analytics),
                        label: const Text('Analyze Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryTeal,
                          disabledBackgroundColor: kBorderGrey,
                          foregroundColor: kOnPrimary,
                          disabledForegroundColor: kTextSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: kHeadlineStyle.copyWith(fontSize: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),

                      // Cancel button (only shown when image is selected)
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const Icon(Icons.close, color: kOutline),
                          label: Text(
                            'Cancel',
                            style: kHeadlineStyle.copyWith(
                              fontSize: 16,
                              color: kOutline,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: kCardHighest,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────────
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: kPrimaryTeal),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
