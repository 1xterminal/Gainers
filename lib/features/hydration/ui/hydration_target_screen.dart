import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hydration_provider.dart';

class HydrationTargetScreen extends ConsumerStatefulWidget {
  const HydrationTargetScreen({super.key});

  @override
  ConsumerState<HydrationTargetScreen> createState() =>
      _HydrationTargetScreenState();
}

class _HydrationTargetScreenState extends ConsumerState<HydrationTargetScreen> {
  late int _selectedTarget;
  final int _minTarget = 1000;
  final int _maxTarget = 5000;
  final int _step = 250;

  @override
  void initState() {
    super.initState();
    final currentTarget = ref.read(dailyTargetProvider).value ?? 2000;
    _selectedTarget = currentTarget;
  }

  void _save() {
    ref.read(dailyTargetProvider.notifier).setTarget(_selectedTarget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate initial item index
    int initialItem = ((_selectedTarget - _minTarget) / _step).round();
    if (initialItem < 0) initialItem = 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Set Daily Target'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                'YOUR GOAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$_selectedTarget ml',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 48),

              // Picker Card
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Selection Highlight
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Picker
                    CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: initialItem,
                      ),
                      itemExtent: 60,
                      magnification: 1.2,
                      useMagnifier: true,
                      diameterRatio: 1.5,
                      selectionOverlay: null,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedTarget = _minTarget + (index * _step);
                        });
                      },
                      children: List.generate(
                        ((_maxTarget - _minTarget) / _step).floor() + 1,
                        (index) {
                          final amount = _minTarget + (index * _step);
                          return Center(
                            child: Text(
                              '$amount ml',
                              style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recommended daily intake is around 2000-3000ml depending on your activity level.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
