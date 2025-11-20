import 'package:flutter/material.dart';

class ExerciseTutorialScreen extends StatelessWidget {
  const ExerciseTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness & Tutorials')),
      body: const Center(child: Text('Exercise Tutorials Screen')),
    );
  }
}
