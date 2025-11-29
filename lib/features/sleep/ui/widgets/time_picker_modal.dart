import 'package:flutter/material.dart';

class TimePickerModal extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerModal({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<TimePickerModal> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const Text(
            'Select Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours Wheel
                SizedBox(
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    controller: _hourController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedHour = index);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 24,
                      builder: (context, index) {
                        final isSelected = index == _selectedHour;
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: isSelected ? 32 : 24,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  ':',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                // Minutes Wheel
                SizedBox(
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    controller: _minuteController,
                    itemExtent: 50,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedMinute = index);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 60,
                      builder: (context, index) {
                        final isSelected = index == _selectedMinute;
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: isSelected ? 32 : 24,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onTimeSelected(TimeOfDay(hour: _selectedHour, minute: _selectedMinute));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
