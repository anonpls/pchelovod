import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kosnice_app/models/hive_entry.dart';
import 'package:kosnice_app/screens/hive_detail_screen.dart';
import 'package:kosnice_app/l10n/app_localizations.dart';

class HiveListScreen extends StatefulWidget {
  const HiveListScreen({super.key});

  @override
  State<HiveListScreen> createState() => _HiveListScreenState();
}

class _HiveListScreenState extends State<HiveListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _sortBy = 'id'; // ili 'name'

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<HiveEntry>('hives');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewHives),
      ),
      body: ValueListenableBuilder<Box<HiveEntry>>(
        valueListenable: box.listenable(),
        builder: (context, Box<HiveEntry> box, _) {
          final hives = box.values
              .where((hive) =>
                  hive.id.toLowerCase().contains(_searchText.toLowerCase()) ||
                  (hive.name?.toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
                  (hive.description?.toLowerCase().contains(_searchText.toLowerCase()) ?? false))
              .toList();

          if (_sortBy == 'id') {
            hives.sort((a, b) => a.id.compareTo(b.id));
          } else if (_sortBy == 'name') {
            hives.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
          }

          if (hives.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noHivesFound));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchText = value),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchLabel,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.sortBy),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _sortBy,
                      onChanged: (value) {
                        if (value != null) setState(() => _sortBy = value);
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'id',
                          child: Text(AppLocalizations.of(context)!.hiveId),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text(AppLocalizations.of(context)!.name),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: hives.length,
                  itemBuilder: (context, index) {
                    final hive = hives[index];
                    return ListTile(
                      title: Text(hive.name ?? AppLocalizations.of(context)!.noNameLabel),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${AppLocalizations.of(context)!.hiveId}: ${hive.id}'),
                          Text('${AppLocalizations.of(context)!.type}: ${hive.type}'),
                          Text('${AppLocalizations.of(context)!.hiveBreed}: ${hive.breed != null && hive.breed!.isNotEmpty ? hive.breed : AppLocalizations.of(context)!.noNameLabel}'),
                          Text('${AppLocalizations.of(context)!.queen}: ${hive.queenPresent == true ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no}'),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HiveDetailScreen(
                              hive: hive,
                              history: hive.history,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
