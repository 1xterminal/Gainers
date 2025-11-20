import 'package:flutter/material.dart';

class SleepLogScreen extends StatelessWidget {
  const SleepLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Log')),
      body: const Center(child: Text('Sleep Log Screen')),
    );
  }
}
