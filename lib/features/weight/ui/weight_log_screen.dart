import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/weight_provider.dart';
import '../../../core/widgets/horizontal_date_wheel.dart';
import 'widgets/weight_input_modal.dart';
import 'widgets/weight_history_list.dart';

class WeightLogScreen extends ConsumerStatefulWidget {
  const WeightLogScreen({super.key});

  @override
  ConsumerState<WeightLogScreen> createState() => _WeightLogScreenState();
}

class _WeightLogScreenState extends ConsumerState<WeightLogScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final profileAsync = ref.watch(getProfileProvider(userId ?? ''));
    final weightNotifier = ref.read(weightProvider.notifier);
    final selectedDate = weightNotifier.selectedDate;
    final weightState = ref.watch(weightProvider);
    final recentLogsAsync = ref.watch(recentWeightLogsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Body composition'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: weightState.when(
        data: (logs) {
          // Get latest log from the list
          final latestLog = logs.isNotEmpty ? logs.first : null;
          
          return profileAsync.when(
            data: (profile) {
              // Priority: Latest Log > Profile > 0
              final weight = latestLog?.weight ?? profile?.weightKg ?? 0.0;
              final heightCm = profile?.heightCm ?? 0;
              final heightM = heightCm / 100.0;
              final bmi = (heightM > 0 && weight > 0) ? weight / (heightM * heightM) : 0.0;
              
              final muscle = latestLog?.skeletalMuscle;
              final fat = latestLog?.bodyFat;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Date Wheel
                          HorizontalDateWheel(
                            selectedDate: selectedDate,
                            onDateSelected: (date) => weightNotifier.setDate(date),
                          ),
                          const SizedBox(height: 24),
                          
                          // Main Weight Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151515),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.monitor_weight, color: Colors.green, size: 32),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: weight),
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeOutExpo,
                                      builder: (context, value, child) {
                                        return Text(
                                          value.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 64,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'kg',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Info Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151515),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // BMI Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('BMI >', style: TextStyle(color: Colors.white, fontSize: 16)),
                                    const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(bmi.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                _buildProgressBar(value: (bmi / 40).clamp(0.0, 1.0), color: Colors.green),
                                const SizedBox(height: 4),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('18.5', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text('25.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                const Divider(color: Colors.grey, height: 1),
                                const SizedBox(height: 24),

                                // Skeletal Muscle Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Skeletal Muscle >', style: TextStyle(color: Colors.white, fontSize: 16)),
                                    const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  muscle != null ? '${muscle.toStringAsFixed(1)} kg' : '--', 
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 8),
                                _buildProgressBar(
                                  value: muscle != null ? (muscle / (weight > 0 ? weight : 100)).clamp(0.0, 1.0) : 0.0, 
                                  color: Colors.blue
                                ),
                                
                                const SizedBox(height: 24),
                                const Divider(color: Colors.grey, height: 1),
                                const SizedBox(height: 24),

                                // Body Fat Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Body Fat >', style: TextStyle(color: Colors.white, fontSize: 16)),
                                    const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  fat != null ? '${fat.toStringAsFixed(1)} %' : '--', 
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 8),
                                _buildProgressBar(
                                  value: fat != null ? (fat / 50).clamp(0.0, 1.0) : 0.0, 
                                  color: Colors.orange
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // History List
                          recentLogsAsync.when(
                            data: (logs) => logs.isNotEmpty 
                              ? WeightHistoryList(logs: logs)
                              : const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
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
                        onPressed: () => _showInputModal(context, weight, muscle, fat),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Enter data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading profile: $err', style: const TextStyle(color: Colors.white))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading weight log: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildProgressBar({required double value, required Color color}) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _showInputModal(BuildContext context, double currentWeight, double? currentMuscle, double? currentFat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => WeightInputModal(
        initialWeight: currentWeight,
        initialMuscle: currentMuscle,
        initialFat: currentFat,
        onSave: (newWeight, newMuscle, newFat, notes) async {
          final notifier = ref.read(weightProvider.notifier);
          final userId = Supabase.instance.client.auth.currentUser?.id;
          
          await notifier.addLog(
            weight: newWeight,
            date: DateTime.now(),
            skeletalMuscle: newMuscle,
            bodyFat: newFat,
            notes: notes,
          );
          
          // Refresh profile to update dashboard
          if (userId != null) {
             ref.invalidate(getProfileProvider(userId));
          }
          
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data saved!')));
          }
        },
      ),
    );
  }
}


