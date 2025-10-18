import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/src.dart';
import 'src/domain/models/splash_screen.dart';

void main() {
  runApp(const LetsDrawApp());
}

const Color kCanvasColor = Color(0xfff2f3f7);
const String kGithubRepo = 'https://github.com/ganesh/flutter_drawing_board';

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