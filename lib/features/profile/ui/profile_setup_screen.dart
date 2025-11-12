// Ini adalah file baru
import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
      ),
      body: const Center(
        child: Text('Profile Setup Screen (Week 2)'),
      ),
    );
  }
}