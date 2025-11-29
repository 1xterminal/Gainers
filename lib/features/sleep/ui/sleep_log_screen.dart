import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/horizontal_date_wheel.dart';
import '../providers/sleep_provider.dart';

class SleepLogScreen extends ConsumerStatefulWidget {
  const SleepLogScreen({super.key});

  @override
  ConsumerState<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends ConsumerState<SleepLogScreen> {
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  @override
  Widget build(BuildContext context) {
    final sleepState = ref.watch(sleepProvider);
    final notifier = ref.read(sleepProvider.notifier);
    final selectedDate = ref.watch(sleepProvider.notifier).selectedDate;
    final theme = Theme.of(context);

    final dailyLogs = sleepState.value ?? [];

    String durationText = '--';
    if (_bedTime != null && _wakeTime != null) {
      final now = DateTime.now();
      final bedDateTime = DateTime(now.year, now.month, now.day, _bedTime!.hour, _bedTime!.minute);
      var wakeDateTime = DateTime(now.year, now.month, now.day, _wakeTime!.hour, _wakeTime!.minute);
      if (wakeDateTime.isBefore(bedDateTime)) {
        wakeDateTime = wakeDateTime.add(const Duration(days: 1));
      }
      final diff = wakeDateTime.difference(bedDateTime);
      durationText = '${diff.inHours}h ${diff.inMinutes % 60}m';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Log'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HorizontalDateWheel(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                notifier.setDate(date);
              },
            ),
            const SizedBox(height: 24),
            
            // Input Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTimePickerTile(
                        context,
                        title: 'Bed Time',
                        icon: Icons.bedtime,
                        color: Colors.purple,
                        time: _bedTime,
                        onTimeSelected: (t) => setState(() => _bedTime = t),
                      ),
                      const Divider(),
                      _buildTimePickerTile(
                        context,
                        title: 'Wake Time',
                        icon: Icons.wb_sunny,
                        color: Colors.orange,
                        time: _wakeTime,
                        onTimeSelected: (t) => setState(() => _wakeTime = t),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(durationText, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_bedTime == null || _wakeTime == null) ? null : () async {
                            final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, _bedTime!.hour, _bedTime!.minute);
                            var end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, _wakeTime!.hour, _wakeTime!.minute);
                            if (end.isBefore(start)) {
                              end = end.add(const Duration(days: 1));
                            }
                            
                            await notifier.addLog(start, end);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sleep log saved!')));
                              setState(() {
                                _bedTime = null;
                                _wakeTime = null;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Log'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            // Logs List
            if (dailyLogs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(alignment: Alignment.centerLeft, child: Text('Today\'s Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailyLogs.length,
                itemBuilder: (context, index) {
                  final log = dailyLogs[index];
                  final hours = log.durationMinutes ~/ 60;
                  final minutes = log.durationMinutes % 60;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515), // Dark background like image
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sleep time',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.bedtime, color: Color(0xFF8B5CF6), size: 32), // Violet icon
                            const SizedBox(width: 12),
                            Text(
                              '${hours}h ${minutes > 0 ? "$minutes" : ""}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (minutes > 0) // Small 'm' if minutes exist, but image shows '13 h'
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'm',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${DateFormat('HH:mm').format(log.startTime)} - ${DateFormat('HH:mm').format(log.endTime)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else 
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No logs for this date', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(BuildContext context, {required String title, required IconData icon, required Color color, required TimeOfDay? time, required Function(TimeOfDay) onTimeSelected}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: Text(
        time?.format(context) ?? 'Select',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time ?? const TimeOfDay(hour: 22, minute: 0));
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
    );
  }
}
