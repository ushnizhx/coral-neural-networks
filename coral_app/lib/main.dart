import 'package:flutter/material.dart';
import 'screens/upload_screen.dart';
import 'theme.dart';

void main() {
  runApp(const CoralApp());
}

class CoralApp extends StatelessWidget {
  const CoralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coral Neural Networks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundLight,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryTeal),
        useMaterial3: true,
      ),
      home: const UploadScreen(),
    );
  }
}
