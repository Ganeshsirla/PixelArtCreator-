import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/src.dart';
import 'domain/models/splash_screen.dart';

class LetsDrawApp extends StatelessWidget {
  const LetsDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Let's Draw",
      theme: lightTheme,
      home: const SplashScreen(), // Start with splash screen instead of DrawingPage
      debugShowCheckedModeBanner: false,
    );
  }
}