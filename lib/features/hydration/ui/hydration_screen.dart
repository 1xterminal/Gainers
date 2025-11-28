import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/hydration_provider.dart';
import 'widgets/wave_progress_widget.dart';
import '../../../core/widgets/horizontal_date_wheel.dart';

class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydrationState = ref.watch(hydrationProvider);
    final notifier = ref.read(hydrationProvider.notifier);
    final selectedDate = ref.watch(hydrationProvider.notifier).selectedDate;

    const int dailyTarget = 2000; // ml

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      body: hydrationState.when(
        data: (logs) {
          final totalIntake = logs.fold(0, (sum, item) => sum + item.amount);
          final progress = (totalIntake / dailyTarget).clamp(0.0, 1.0);
          final percentage = (progress * 100).toInt();

          // Motivational Text Logic
          String motivationalText = "Start your day!";
          if (percentage >= 100) {
            motivationalText = "Hydrated & Healthy! 🎉";
          } else if (percentage >= 50) {
            motivationalText = "Halfway there! 🌊";
          } else if (percentage > 0) {
            motivationalText = "Keep drinking!";
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Date Wheel
                HorizontalDateWheel(
                  selectedDate: selectedDate,
                  onDateSelected: (date) => notifier.setDate(date),
                ),

                const SizedBox(height: 24),

                // 1. Header: Total vs Target
                Column(
                  children: [
                    Text(
                      'Today\'s Intake',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                        children: [
                          TextSpan(text: '$totalIntake'),
                          TextSpan(
                            text: ' / $dailyTarget ml',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 2. The Visual: Filling Circle
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Circle border
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.1),
                            width: 2,
                          ),
                        ),
                      ),
                      // Wave Widget
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: WaveProgressWidget(
                            progress: progress,
                            size: 240,
                            color: Colors.cyanAccent, // Cyan color as requested
                          ),
                        ),
                      ),
                      // Center Content (Percentage & Icon)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 48,
                            color: progress > 0.5 ? Colors.white : Colors.cyan,
                            shadows: [
                              if (progress > 0.5)
                                const Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4.0,
                                  color: Colors.black26,
                                ),
                            ],
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: progress > 0.5
                                  ? Colors.white
                                  : Colors.black87,
                              shadows: [
                                if (progress > 0.5)
                                  const Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4.0,
                                    color: Colors.black26,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Motivational Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    motivationalText,
                    key: ValueKey(motivationalText),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.cyan,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 4. Quick Add Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAddButton(
                        context,
                        icon: Icons.local_drink_outlined,
                        label: '250ml',
                        amount: 250,
                        onTap: () => notifier.addLog(250),
                      ),
                      _buildQuickAddButton(
                        context,
                        icon: Icons.water_drop_outlined,
                        label: '500ml',
                        amount: 500,
                        onTap: () => notifier.addLog(500),
                      ),
                      _buildQuickAddButton(
                        context,
                        icon: Icons.add,
                        label: 'Custom',
                        amount: 0,
                        onTap: () => _showCustomAmountDialog(context, notifier),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Daily Log (Timeline)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, d MMM').format(selectedDate),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (logs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              "No water logged yet.\nStart your day!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final sortedLogs = List.from(logs)
                              ..sort(
                                (a, b) => b.timestamp.compareTo(a.timestamp),
                              );
                            final log = sortedLogs[index];

                            return Dismissible(
                              key: Key(log.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.redAccent,
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) {
                                notifier.deleteLog(log.id);
                              },
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.water_drop,
                                    color: Colors.cyan,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${log.amount} ml',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat('h:mm a').format(log.timestamp),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int amount,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.cyan.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Colors.cyan),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showCustomAmountDialog(
    BuildContext context,
    HydrationNotifier notifier,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            hintText: 'e.g. 300',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                notifier.addLog(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
