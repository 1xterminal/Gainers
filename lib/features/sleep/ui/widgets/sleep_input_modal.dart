import 'package:flutter/material.dart';
import 'time_picker_modal.dart';

class SleepInputModal extends StatefulWidget {
  final Function(TimeOfDay bedTime, TimeOfDay wakeTime) onSave;

  const SleepInputModal({
    super.key,
    required this.onSave,
  });

  @override
  State<SleepInputModal> createState() => _SleepInputModalState();
}

class _SleepInputModalState extends State<SleepInputModal> {
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  String get durationText {
    if (_bedTime == null || _wakeTime == null) return '--';
    
    final now = DateTime.now();
    final bedDateTime = DateTime(now.year, now.month, now.day, _bedTime!.hour, _bedTime!.minute);
    var wakeDateTime = DateTime(now.year, now.month, now.day, _wakeTime!.hour, _wakeTime!.minute);
    
    if (wakeDateTime.isBefore(bedDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }
    
    final diff = wakeDateTime.difference(bedDateTime);
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Log Sleep',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // Time Pickers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(24),
            ),
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
                const Divider(color: Color(0xFF333333)),
                _buildTimePickerTile(
                  context,
                  title: 'Wake Time',
                  icon: Icons.wb_sunny,
                  color: Colors.orange,
                  time: _wakeTime,
                  onTimeSelected: (t) => setState(() => _wakeTime = t),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Duration Display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Duration',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  durationText,
                  style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Buttons
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_bedTime == null || _wakeTime == null)
                      ? null
                      : () {
                          widget.onSave(_bedTime!, _wakeTime!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required TimeOfDay? time,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        time?.format(context) ?? 'Select',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => TimePickerModal(
            initialTime: time ?? const TimeOfDay(hour: 22, minute: 0),
            onTimeSelected: onTimeSelected,
          ),
        );
      },
    );
  }
}
