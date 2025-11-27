import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/weight_provider.dart";

class WeightLogPage extends ConsumerWidget {
  const WeightLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightLogs = ref.watch(weightLogsProvider);
    final notifier = ref.read(weightLogsProvider.notifier);

    final logs = weightLogs.value ?? [];

    if (logs.isEmpty) {
      return const Center(child: Text('Weight Logs are empty'));
    } else if (weightLogs.hasError) {
      return Center(
        child: Text('Error while fetching weight logs: ${weightLogs.error}'),
      );
    }

    return ListView.separated(
      itemCount: logs.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        title: Text('Weight ${logs[index].createdAt}'),
        trailing: Text('Weight: ${logs[index].weight}'),
      ),
    );
  }
}
