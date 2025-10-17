

import 'package:flutter/material.dart';
import 'package:kosnice_app/models/hive_check_entry.dart';

class HiveHistoryScreen extends StatelessWidget {
  final List<HiveCheckEntry> history;

  const HiveHistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Istorija pregleda')),
      body: history.isEmpty
          ? const Center(child: Text('Nema sačuvanih stanja za ovu košnicu.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return ListTile(
                  title: Text(
                      'Datum: ${entry.timestamp.toLocal().toString().substring(0, 16)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.frames != null) Text('Okvira: ${entry.frames}'),
                      if (entry.total != null) Text('Ukupno: ${entry.total}'),
                      if (entry.brood != null) Text('Leglo: ${entry.brood}'),
                      if (entry.honey != null) Text('Med: ${entry.honey}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}