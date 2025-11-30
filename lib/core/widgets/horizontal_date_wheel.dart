import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorizontalDateWheel extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const HorizontalDateWheel({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<HorizontalDateWheel> createState() => _HorizontalDateWheelState();
}

class _HorizontalDateWheelState extends State<HorizontalDateWheel> {
  late FixedExtentScrollController _controller;
  final int _initialItem = 5000; // Start in the middle to allow past/future

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _initialItem);
  }

  @override
  void didUpdateWidget(covariant HorizontalDateWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      // If date changed externally, we might want to scroll to it.
      // For now, we assume the parent updates based on this widget's callback,
      // so we don't force scroll to avoid loops, unless strictly necessary.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 100,
      child: RotatedBox(
        quarterTurns: -1, // Rotate to make it horizontal
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: 80, // Width of each date item (height after rotation)
          perspective: 0.005,
          diameterRatio: 1.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            final daysDifference = index - _initialItem;
            final newDate = DateTime.now().add(Duration(days: daysDifference));
            widget.onDateSelected(newDate);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: _initialItem + 1,
            builder: (context, index) {
              final daysDifference = index - _initialItem;
              final date = DateTime.now().add(Duration(days: daysDifference));
              final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
              final isToday = DateUtils.isSameDay(date, DateTime.now());

              return RotatedBox(
                quarterTurns: 1, // Rotate back content
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor
                        : theme.cardColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: isToday && !isSelected
                        ? Border.all(color: theme.primaryColor, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color?.withValues(
                                  alpha: 0.6,
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
