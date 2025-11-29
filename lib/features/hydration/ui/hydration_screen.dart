import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../providers/hydration_provider.dart';
import 'widgets/water_progress_circle.dart';
import 'widgets/hydration_history_list.dart';
import '../../../core/widgets/horizontal_date_wheel.dart';
import 'hydration_target_screen.dart';

class HydrationScreen extends ConsumerStatefulWidget {
  const HydrationScreen({super.key});

  @override
  ConsumerState<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends ConsumerState<HydrationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final hydrationState = ref.watch(hydrationProvider);
    final notifier = ref.read(hydrationProvider.notifier);
    final selectedDate = ref.watch(hydrationProvider.notifier).selectedDate;
    final dailyTargetAsync = ref.watch(dailyTargetProvider);
    final dailyTarget = dailyTargetAsync.value ?? 2000;

    // Listen for target reached to play confetti
    ref.listen(hydrationProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final totalIntake = next.value!.fold(
          0,
          (sum, item) => sum + item.amount,
        );
        final previousTotal =
            previous?.value?.fold(0, (sum, item) => sum + item.amount) ?? 0;

        if (totalIntake >= dailyTarget && previousTotal < dailyTarget) {
          _confettiController.play();
        }
      }
    });

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
      body: Stack(
        children: [
          hydrationState.when(
            data: (logs) {
              final totalIntake = logs.fold(
                0,
                (sum, item) => sum + item.amount,
              );
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: TweenAnimationBuilder<int>(
                                      tween: IntTween(
                                        begin: 0,
                                        end: totalIntake,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      curve: Curves.easeOutExpo,
                                      builder: (context, value, child) {
                                        return Text(
                                          '$value',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                        );
                                      },
                                    ),
                                  ),
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
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              color: Colors.grey[400],
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HydrationTargetScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 2. The Visual: Filling Circle
                    WaterProgressCircle(
                      progress: progress,
                      percentage: percentage,
                    ),

                    const SizedBox(height: 32),

                    // 3. Motivational Text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.5),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: Text(
                          motivationalText,
                          key: ValueKey(motivationalText),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

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
                            onTap: () =>
                                _showCustomAmountDialog(context, notifier),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 5. Daily Log (Timeline)
                    HydrationHistoryList(
                      logs: logs,
                      selectedDate: selectedDate,
                      notifier: notifier,
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
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
