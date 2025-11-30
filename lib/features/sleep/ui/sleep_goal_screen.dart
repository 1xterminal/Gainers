import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sleep_provider.dart';

class SleepGoalScreen extends ConsumerStatefulWidget {
  const SleepGoalScreen({super.key});

  @override
  ConsumerState<SleepGoalScreen> createState() => _SleepGoalScreenState();
}

class _SleepGoalScreenState extends ConsumerState<SleepGoalScreen> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  int _selectedHour = 8;
  int _selectedMinute = 0;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );

    // Load existing goal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goal = ref.read(sleepGoalProvider).value;
      if (goal != null) {
        setState(() {
          _selectedHour = goal.targetHours;
          _selectedMinute = goal.targetRemainingMinutes;
          _hourController.jumpToItem(_selectedHour);
          _minuteController.jumpToItem(_selectedMinute);
        });
      }
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Set Sleep Goal'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 48),
          const Text(
            'How much sleep do you need?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recommended: 7-9 hours',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 48),

          // Time Wheel
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hours
                    SizedBox(
                      width: 70,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourController,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) =>
                            setState(() => _selectedHour = index),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final isSelected = index == _selectedHour;
                            return Center(
                              child: Text(
                                index.toString(),
                                style: TextStyle(
                                  fontSize: isSelected ? 32 : 20,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                            );
                          },
                          childCount: 13, // 0-12 hours
                        ),
                      ),
                    ),
                    const Text(
                      'h',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Minutes
                    SizedBox(
                      width: 70,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteController,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) =>
                            setState(() => _selectedMinute = index),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final isSelected = index == _selectedMinute;
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: isSelected ? 32 : 20,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                            );
                          },
                          childCount: 60,
                        ),
                      ),
                    ),
                    const Text(
                      'm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final totalMinutes = (_selectedHour * 60) + _selectedMinute;
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  await ref
                      .read(sleepGoalProvider.notifier)
                      .setGoal(totalMinutes);

                  if (mounted) {
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Sleep goal saved!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6), // Violet
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Save Goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
