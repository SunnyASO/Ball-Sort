import 'package:flutter/material.dart';

import 'screens/game_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BallSortApp());
}

/// Root application widget for Ball Sort.
class BallSortApp extends StatelessWidget {
  const BallSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ball Sort',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const GameScreen(),
    );
  }
}
