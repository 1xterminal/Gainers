import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/hydration_model.dart';
import '../../providers/hydration_provider.dart';
import '../hydration_edit_screen.dart';

class HydrationHistoryList extends StatelessWidget {
  final List<HydrationLog> logs;
  final DateTime selectedDate;
  final HydrationNotifier notifier;

  const HydrationHistoryList({
    super.key,
    required this.logs,
    required this.selectedDate,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('EEEE, d MMM').format(selectedDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sortedLogs = List.from(logs)
                  ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HydrationEditScreen(log: log),
                        ),
                      );
                    },
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
