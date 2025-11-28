import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../providers/weight_provider.dart";
import "../data/weight_model.dart";

class WeightLogScreen extends ConsumerStatefulWidget {
  const WeightLogScreen({super.key});

  @override
  ConsumerState<WeightLogScreen> createState() => _WeightLogScreenState();
}

class _WeightLogScreenState extends ConsumerState<WeightLogScreen> {
  @override
  Widget build(BuildContext context) {
    final weightLogs = ref.watch(weightLogsProvider);

    final logs = weightLogs.value ?? [];

    if (logs.isEmpty) {
      return const Center(child: Text('Weight Logs are empty'));
    } else if (weightLogs.hasError) {
      return Center(
        child: Text('Error while fetching weight logs: ${weightLogs.error}'),
      );
    }

    if (weightLogs.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
			appBar: AppBar(title: const Text('Weight Logs')),
			body: ListView.separated(
				itemCount: logs.length,
				separatorBuilder: (context, index) => const Divider(
					height: 1,
					indent: 16,
					color: Color.fromARGB(64, 128, 128, 128),
					endIndent: 16,
				),
				itemBuilder: (context, index) => Dismissible(
					key: Key(logs[index].id.toString()),
					direction: DismissDirection.endToStart,
					background: Container(
						color: Colors.red,
						alignment: Alignment.centerRight,
						padding: const EdgeInsets.only(right: 20),
						child: const Icon(Icons.delete, color: Colors.white),
					),
					onDismissed: (direction) {
						if (logs[index].id != null) {
							ref.read(weightLogsProvider.notifier).deleteLog(logs[index].id!);
							ScaffoldMessenger.of(
								context,
							).showSnackBar(SnackBar(content: Text('Log successfully deleted')));
						}
					},
					child: ListTile(
						title: Text(
							'${logs[index].weight_kg} kg',
							style: TextStyle(fontWeight: FontWeight.bold),
						),
						trailing: Text(
							DateFormat('dd MMM yyyy').format(logs[index].createdAt),
						),
						onTap: () => _showModalSheet(context, ref, log: logs[index]),
					),
				),
			),
			floatingActionButton: FloatingActionButton(
          onPressed: () => _showModalSheet(context, ref),
          tooltip: 'Add Weight',
          child: const Icon(Icons.add),
        )
		);
  }

  void _showModalSheet(BuildContext context, WidgetRef ref, {WeightLog? log}) {
    final weightCtrl = TextEditingController(
      text: log?.weight_kg.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        // title: const Text('Add Weight Log'),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                log == null ? 'Add Weight Log' : 'Edit Weight Log',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: weightCtrl,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (weightCtrl.text.isEmpty) return;

                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  if (userId == null) return;

                  final weightLog = WeightLog(
                    id: log?.id, // Keep ID if editing
                    userId: userId,
                    weight_kg: double.tryParse(weightCtrl.text) ?? 0.0,
                    createdAt: DateTime.now(),
                  );

                  if (weightLog.id != null) {
                    ref.read(weightLogsProvider.notifier).updateLog(weightLog);
                  } else {
                    ref.read(weightLogsProvider.notifier).addLog(weightLog);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Log successfully ${log == null ? 'added' : 'updated'}',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(log == null ? 'Add Weight' : 'Save Changes'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
