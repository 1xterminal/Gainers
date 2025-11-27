import 'package:flutter/material.dart';
import 'package:gainers/features/progress/ui/weight_log_page.dart';
import "./progress_screen.dart";

class ProgressScreen extends StatefulWidget {
	final int initialScreenIndex;
  const ProgressScreen({
		super.key,
		this.initialScreenIndex = 0
	});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
			initialIndex: widget.initialScreenIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progress'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Steps', icon: Icon(Icons.directions_walk)),
              Tab(text: 'Calories', icon: Icon(Icons.local_fire_department)),
              Tab(text: 'Sleep', icon: Icon(Icons.bed)),
              Tab(text: 'Weight', icon: Icon(Icons.monitor_weight)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Steps')),
            Center(child: Text('Calories')),
            Center(child: Text('Sleep')),
            WeightLogPage(),
          ],
        ),
      ),
    );
  }
}
