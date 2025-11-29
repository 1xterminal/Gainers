import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/horizontal_date_wheel.dart';
import '../providers/sleep_provider.dart';
import 'widgets/sleep_input_modal.dart';

class SleepLogScreen extends ConsumerStatefulWidget {
  const SleepLogScreen({super.key});

  @override
  ConsumerState<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends ConsumerState<SleepLogScreen> {
  @override
  Widget build(BuildContext context) {
    final sleepState = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);
    final selectedDate = ref.watch(sleepProvider.notifier).selectedDate;

    final dailyLogs = sleepState.value ?? [];
    
    // Calculate total sleep duration for today
    final totalMinutes = dailyLogs.fold<int>(
      0,
      (sum, log) => sum + log.durationMinutes,
    );
    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sleep'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date Wheel
                  HorizontalDateWheel(
                    selectedDate: selectedDate,
                    onDateSelected: (date) => notifier.setDate(date),
                  ),
                  const SizedBox(height: 24),

                  // Main Sleep Duration Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.bedtime, color: Color(0xFF8B5CF6), size: 32),
                        const SizedBox(height: 16),
                        const Text(
                          'Total Sleep',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: totalHours),
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOutExpo,
                              builder: (context, value, child) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'h',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (remainingMinutes > 0) ...[
                              const SizedBox(width: 12),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(begin: 0, end: remainingMinutes),
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOutExpo,
                                builder: (context, value, child) {
                                  return Text(
                                    value.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'm',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logs List
                  if (dailyLogs.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFF151515),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "History",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dailyLogs.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFF333333),
                            ),
                            itemBuilder: (context, index) {
                              final log = dailyLogs[index];
                              final hours = log.durationMinutes ~/ 60;
                              final minutes = log.durationMinutes % 60;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.bedtime,
                                    color: Color(0xFF8B5CF6),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${hours}h ${minutes}m',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  '${DateFormat('HH:mm').format(log.startTime)} - ${DateFormat('HH:mm').format(log.endTime)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No sleep logged yet.\nStart tracking!',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showInputModal(context, notifier, selectedDate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  'Log Sleep',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInputModal(BuildContext context, notifier, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SleepInputModal(
        onSave: (bedTime, wakeTime) async {
          final start = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            bedTime.hour,
            bedTime.minute,
          );
          var end = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            wakeTime.hour,
            wakeTime.minute,
          );
          if (end.isBefore(start)) {
            end = end.add(const Duration(days: 1));
          }

          await notifier.addLog(start, end);
          
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sleep log saved!')),
            );
          }
        },
      ),
    );
  }
}
