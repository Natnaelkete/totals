import 'package:flutter/material.dart';
import 'package:totals/models/failed_parse.dart';
import 'package:totals/repositories/failed_parse_repository.dart';

Future<void> showFailedParseDialog(BuildContext context) async {
  final repo = FailedParseRepository();

  await showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<List<FailedParse>>(
        future: repo.getAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          return AlertDialog(
            title: const Text("Failed SMS Parsings"),
            content: SizedBox(
              width: double.maxFinite,
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Text("No failed parsings.")
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 8),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.address,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.reason,
                                  style:
                                      const TextStyle(color: Colors.redAccent),
                                ),
                                const SizedBox(height: 4),
                                Text(item.body),
                                const SizedBox(height: 4),
                                Text(
                                  item.timestamp,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            );
                          },
                        ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
              TextButton(
                onPressed: () async {
                  await repo.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cleared failed parsings")),
                    );
                  }
                },
                child: const Text("Clear All"),
              ),
            ],
          );
        },
      );
    },
  );
}
