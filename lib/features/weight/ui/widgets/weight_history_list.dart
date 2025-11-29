import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/weight_model.dart';

class WeightHistoryList extends StatelessWidget {
  final List<WeightLog> logs;

  const WeightHistoryList({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515), // Dark background to match Weight screen
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "No weight logged yet.\nStart tracking!",
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
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF333333)),
              itemBuilder: (context, index) {
                final log = logs[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monitor_weight,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${log.weight} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    DateFormat('MMM d, h:mm a').format(log.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: log.bodyFat != null 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${log.bodyFat}%', 
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                          const Text('Body Fat', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      )
                    : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
