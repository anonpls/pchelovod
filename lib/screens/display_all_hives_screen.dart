import 'package:flutter/material.dart';
import 'package:kosnice_app/models/hive_entry.dart';
import 'package:hive/hive.dart';
import 'package:kosnice_app/l10n/app_localizations.dart';

class HiveListScreen extends StatefulWidget {
  const HiveListScreen({super.key});

  @override
  State<HiveListScreen> createState() => _HiveListScreenState();
}

class _HiveListScreenState extends State<HiveListScreen> {
  late List<HiveEntry> hives;
  final TextEditingController _searchController = TextEditingController();
  String filterText = '';

  @override
  void initState() {
    super.initState();
    hives = Hive.box<HiveEntry>('kosnice').values.toList();
    _searchController.addListener(() {
      setState(() {
        filterText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredHives = hives.where((hive) {
      final id = hive.id.toLowerCase();
      final name = (hive.name ?? '').toLowerCase();
      final desc = (hive.description ?? '').toLowerCase();
      final tags = hive.tags.map((tag) => tag.toLowerCase()).join(' ');
      return id.contains(filterText) || name.contains(filterText) || desc.contains(filterText) || tags.contains(filterText);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.allHivesTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'ID') {
                  hives.sort((a, b) => a.id.compareTo(b.id));
                } else if (value == 'Naziv') {
                  hives.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
                } else if (value == 'Tip') {
                  hives.sort((a, b) => a.type.compareTo(b.type));
                } else if (value == 'Tagovi') {
                  hives.sort((a, b) => b.tags.length.compareTo(a.tags.length));
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'ID',
                  child: Text('${AppLocalizations.of(context)!.sortBy} ID')),
              PopupMenuItem(
                  value: 'Naziv',
                  child: Text('${AppLocalizations.of(context)!.sortBy} ${AppLocalizations.of(context)!.name}')),
              PopupMenuItem(
                  value: 'Tip',
                  child: Text('${AppLocalizations.of(context)!.sortBy} ${AppLocalizations.of(context)!.type}')),
              PopupMenuItem(
                  value: 'Tagovi',
                  child: Text('${AppLocalizations.of(context)!.sortBy} tagovi')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHives.length,
              itemBuilder: (context, index) {
                final hive = filteredHives[index];
                return ListTile(
                  title: Text(
                    '${((hive.name ?? AppLocalizations.of(context)!.noNameLabel)).toUpperCase()} - ${AppLocalizations.of(context)!.hiveId}: ${hive.id}',
                  ),
                  isThreeLine: true,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final parts = <String>[];
                          parts.add('${AppLocalizations.of(context)!.type}: ${hive.type}');
                          if (hive.queenPresent != null) {
                            parts.add('${AppLocalizations.of(context)!.queenSectionTitle}: '
                                '${hive.queenPresent == true ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no}');
                          }
                          if (hive.frames != null) {
                            parts.add('${AppLocalizations.of(context)!.hiveType}: ${hive.frames}');
                          }
                          return Text(parts.join(' | '));
                        },
                      ),
                      if (hive.tags != null && hive.tags!.isNotEmpty)
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: hive.tags!.map((tag) => Chip(label: Text(tag))).toList(),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to detail screen or handle tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}