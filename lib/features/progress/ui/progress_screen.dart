import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/weight/ui/weight_log_screen.dart';
import 'package:gainers/features/weight/data/weight_model.dart';
import 'package:gainers/features/weight/providers/weight_provider.dart';
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

	// WIP
	// late WeightLogPage weightLogPage;

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

		// weightLogPage = const WeightLogPage();
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
          Center(child: Text('Weight')),
        ],
      ),
    );
  }
}
