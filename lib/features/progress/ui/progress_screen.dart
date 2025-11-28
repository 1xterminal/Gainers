import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/progress/ui/weight_log_page.dart';
import 'package:gainers/features/progress/data/weight_model.dart';
import 'package:gainers/features/progress/providers/weight_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  final int initialScreenIndex;
  const ProgressScreen({super.key, this.initialScreenIndex = 0});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late TabController _tabController;

	late WeightLogPage weightLogPage;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialScreenIndex;

    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

		weightLogPage = const WeightLogPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Steps', icon: Icon(Icons.directions_walk)),
            Tab(text: 'Calories', icon: Icon(Icons.local_fire_department)),
            Tab(text: 'Sleep', icon: Icon(Icons.bed)),
            Tab(text: 'Weight', icon: Icon(Icons.monitor_weight)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text('Steps')),
          Center(child: Text('Calories')),
          Center(child: Text('Sleep')),
          weightLogPage
        ],
      ),
      floatingActionButton: _getFabForCurrentTab(),
    );
  }

  Widget? _getFabForCurrentTab() {
    switch (_currentIndex) {
      case 3:
        return FloatingActionButton(
          onPressed: () => weightLogPage.showModalSheet(context, ref),
          tooltip: 'Add Weight',
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  // void _showAddWeightDialog(BuildContext context, WidgetRef ref) {
  //   final weightCtrl = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Add Weight Log'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextFormField(
  //               controller: weightCtrl,
  //               decoration: const InputDecoration(
  //                 labelText: 'Weight (kg)',
  //               ),
  //               keyboardType: TextInputType.number,
  //               autofocus: true,
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             if (weightCtrl.text.isEmpty) return;

  //             final userId = Supabase.instance.client.auth.currentUser?.id;
  //             if (userId == null) return;

  //             final log = WeightLog(
  //               userId: userId,
  //               weight_kg: double.tryParse(weightCtrl.text) ?? 0.0,
  //               createdAt: DateTime.now(),
  //             );

  //             ref.read(weightLogsProvider.notifier).addLog(log);
  //             Navigator.pop(ctx);
  //           },
  //           child: const Text('Save'),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
