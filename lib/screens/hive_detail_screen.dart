import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosnice_app/models/hive_entry.dart';
import 'package:kosnice_app/models/hive_check_entry.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kosnice_app/screens/show_qr_code_screen.dart';
import 'package:kosnice_app/screens/hive_history_screen.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';


class HiveDetailScreen extends StatefulWidget {
  final HiveEntry hive;
  final List<HiveCheckEntry> history;

  const HiveDetailScreen({
    super.key,
    required this.hive,
    required this.history,
  });

  @override
  State<HiveDetailScreen> createState() => _HiveDetailScreenState();
}

class _HiveDetailScreenState extends State<HiveDetailScreen> {
  late List<HiveCheckEntry> history;
  late final HiveEntry hive;
  final picker = ImagePicker();
  bool? _queenPresent; // Podaci o matici: DA (true) / NE (false)

  @override
  void initState() {
    super.initState();
    hive = widget.hive;
    history = [...hive.history];
    _queenPresent = hive.queenPresent;
  }


  Future<void> _addImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                // Zamena pickFromGallery sa addImage
                title: Text(AppLocalizations.of(context)!.addImage),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                // Zamena takeWithCamera sa addImage (najbliže dostupno)
                title: Text(AppLocalizations.of(context)!.addImage),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        hive.imagePaths = List.from(hive.imagePaths)..add(pickedFile.path);
        hive.save();
      });
    }
  }

  Future<void> _exportSingleHiveAsCSV() async {
    final csv = StringBuffer();
    csv.writeln('${AppLocalizations.of(context)!.hiveId};${AppLocalizations.of(context)!.name};${AppLocalizations.of(context)!.description};${AppLocalizations.of(context)!.type};notes');
    csv.writeln('${hive.id};${hive.name ?? ""};${hive.description ?? ""};${hive.type};${hive.notes.length}');
    csv.writeln('');
    csv.writeln('${AppLocalizations.of(context)!.addNote}:');
    for (final note in hive.notes) {
      csv.writeln('- $note');
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/kosnica_${hive.id}.csv');
      await file.writeAsString(csv.toString());

      await Share.shareXFiles([XFile(file.path)], text: 'Hive ${hive.id}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveChanges)), // Najbliže dostupno
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hiveId + ' ${hive.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppLocalizations.of(context)!.saveChanges, // Zamena za editData
            onPressed: () async {
              final updated = await showDialog<Map<String, String?>>(
                context: context,
                builder: (context) {
                  final nameController = TextEditingController(text: hive.name ?? '');
                  final descController = TextEditingController(text: hive.description ?? '');
                  final breedController = TextEditingController(text: hive.breed ?? '');
                  String type = hive.type;

                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.hiveId),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hiveName),
                          ),
                          TextField(
                            controller: descController,
                            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                          ),
                          TextField(
                            controller: breedController,
                            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hiveBreed),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: type,
                            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hiveType),
                            items: ['LR', 'DB'].map((t) {
                              return DropdownMenuItem(value: t, child: Text(t));
                            }).toList(),
                            onChanged: (val) => type = val ?? hive.type,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.continueLabel)),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, {
                          'name': nameController.text,
                          'desc': descController.text,
                          'breed': breedController.text,
                          'type': type,
                        }),
                        child: Text(AppLocalizations.of(context)!.saveChanges),
                      ),
                    ],
                  );
                },
              );

              if (updated != null) {
                setState(() {
                  hive = HiveEntry(
                    id: hive.id,
                    name: updated['name'],
                    description: updated['desc'],
                    type: updated['type'] ?? hive.type,
                    tags: hive.tags,
                    notes: hive.notes,
                    imagePaths: hive.imagePaths,
                    latitude: hive.latitude,
                    longitude: hive.longitude,
                    frames: hive.frames,
                    total: hive.total,
                    brood: hive.brood,
                    honey: hive.honey,
                    history: [...hive.history],
                    breed: (updated['breed'] != null && updated['breed']!.isNotEmpty) ? updated['breed'] : hive.breed,
                    queenPresent: hive.queenPresent,
                  );
                  hive.save();
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _addImage,
            tooltip: AppLocalizations.of(context)!.addImage,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: AppLocalizations.of(context)!.exportAllData, // Zamena za exportCSV
            onPressed: _exportSingleHiveAsCSV,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: AppLocalizations.of(context)!.scanQR, // Zamena za showQR
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShowQRCodeScreen(hive: hive),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: AppLocalizations.of(context)!.saveChanges, // Zamena za deleteHive
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.continueLabel),
                  content: Text(AppLocalizations.of(context)!.saveChanges),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.continueLabel)),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.saveChanges)),
                  ],
                ),
              );

              if (confirm == true) {
                await hive.delete();
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('${AppLocalizations.of(context)!.name}: ${hive.name ?? ""}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.description}: ${hive.description ?? ""}'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.type}: ${hive.type}'),
            Text('${AppLocalizations.of(context)!.hiveBreed}: ${hive.breed ?? ""}'),
            if (hive.frames != null) Text('${AppLocalizations.of(context)!.hiveStrength}: ${hive.frames}'),
            if (hive.total != null) Text('${AppLocalizations.of(context)!.total}: ${hive.total}'),
            if (hive.brood != null) Text('${AppLocalizations.of(context)!.brood}: ${hive.brood}'),
            if (hive.honey != null) Text('${AppLocalizations.of(context)!.honey}: ${hive.honey}'),
            if (hive.latitude != null && hive.longitude != null) ...[
              const SizedBox(height: 8),
              Text('Lat: ${hive.latitude!.toStringAsFixed(5)}, Lon: ${hive.longitude!.toStringAsFixed(5)}'),
            ],
            const SizedBox(height: 16),
            // Uklonjen jer nema tags u AppLocalizations
            //Text(AppLocalizations.of(context)!.tags, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: hive.tags.map((tag) {
                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      hive.tags = List.from(hive.tags)..remove(tag);
                      hive.save();
                    });
                  },
                  child: Chip(label: Text(tag)),
                );
              }).toList(),
            ),
            // Uklonjen tag dialog jer nema addTag u AppLocalizations
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            // Zamena: notes -> addNote
            Text(AppLocalizations.of(context)!.addNote, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final note = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String tempNote = '';
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.addNote),
                      content: TextField(
                        autofocus: true,
                        onChanged: (value) => tempNote = value,
                        decoration: InputDecoration(hintText: AppLocalizations.of(context)!.description),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.continueLabel)),
                        ElevatedButton(onPressed: () => Navigator.pop(context, tempNote), child: Text(AppLocalizations.of(context)!.saveChanges)),
                      ],
                    );
                  },
                );

                if (note != null && note.trim().isNotEmpty) {
                  setState(() {
                    hive.notes = List.from(hive.notes)..insert(0, note.trim());
                    hive.save();
                  });
                }
              },
              icon: const Icon(Icons.note_add),
              label: Text(AppLocalizations.of(context)!.addNote),
            ),
            const SizedBox(height: 8),
            if (hive.notes.isEmpty)
              Text(AppLocalizations.of(context)!.noNotes)
            else
              ...hive.notes.map((n) => ListTile(
                title: Text(n),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      hive.notes = List.from(hive.notes)..remove(n);
                      hive.save();
                    });
                  },
                ),
              )),
            const SizedBox(height: 8),
            // Podaci o matici (DA/NE)
            Text(
              AppLocalizations.of(context)!.queenSectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _queenPresent == true ? Colors.green : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _queenPresent = true;
                        hive.queenPresent = true;
                        hive.save();
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.yes),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _queenPresent == false ? Colors.red : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _queenPresent = false;
                        hive.queenPresent = false;
                        hive.save();
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.no),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // DODATNO: Dugme za modal sa dodatnim informacijama
            TextButton.icon(
              onPressed: _showAdditionalInfoDialog,
              icon: const Icon(Icons.add_chart),
              label: Text(AppLocalizations.of(context)!.addStatus), // addStatus postoji
            ),
            const SizedBox(height: 16),
            // Uklonjen statusHistory i noStatus, zamena:
            Text(AppLocalizations.of(context)!.addStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (history.isEmpty)
              Text(AppLocalizations.of(context)!.noNotes)
            else
              ...history.map((entry) => Card(
                child: ListTile(
                  title: Text('${AppLocalizations.of(context)!.addStatus}: ${entry.timestamp.toLocal().toString().split(".").first}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.frames != null) Text('${AppLocalizations.of(context)!.hiveStrength}: ${entry.frames}'),
                      if (entry.total != null) Text('${AppLocalizations.of(context)!.total}: ${entry.total}'),
                      if (entry.brood != null) Text('${AppLocalizations.of(context)!.brood}: ${entry.brood}'),
                      if (entry.honey != null) Text('${AppLocalizations.of(context)!.honey}: ${entry.honey}'),
                    ],
                  ),
                ),
              )),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HiveHistoryScreen(history: history.toList()),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: Text(AppLocalizations.of(context)!.viewFullHistory),
            ),
            const Divider(),
            // Uklonjen images, noImages, delete, close
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hive.imagePaths.isEmpty)
                  Text(AppLocalizations.of(context)!.noImages),
                if (hive.imagePaths.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hive.imagePaths.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final path = hive.imagePaths[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.file(File(path)),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        hive.imagePaths = List.from(hive.imagePaths)..removeAt(index);
                                        hive.save();
                                      });
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: Text(AppLocalizations.of(context)!.saveChanges),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(AppLocalizations.of(context)!.continueLabel),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Image.file(File(path), fit: BoxFit.cover),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(AppLocalizations.of(context)!.addImage),
                ),
              ],
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await hive.save();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.hiveSaved)),
                );
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save),
            label: Text(AppLocalizations.of(context)!.saveChanges),
          ),
        ]),
      ),
    );
  }
}

// Kraj klase _HiveDetailScreenState

// Prebacujemo _showAdditionalInfoDialog u samu klasu _HiveDetailScreenState zbog setState
extension on _HiveDetailScreenState {
  Future<void> _showAdditionalInfoDialog() async {
    final okvirController = TextEditingController(
        text: hive.frames?.toString() ?? '');
    final ukupnoController = TextEditingController(
        text: hive.total?.toString() ?? '');
    final legloController = TextEditingController(
        text: hive.brood?.toString() ?? '');
    final medController = TextEditingController(
        text: hive.honey?.toString() ?? '');
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.addStatus, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                TextField(
                  controller: okvirController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.hiveStrength,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ukupnoController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.total,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: legloController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.brood,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: medController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.honey,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Dodaj novi unos u lokalnu history listu
                          history.insert(
                            0,
                            HiveCheckEntry(
                              timestamp: DateTime.now(),
                              frames: int.tryParse(okvirController.text),
                              total: int.tryParse(ukupnoController.text),
                              brood: int.tryParse(legloController.text),
                              honey: int.tryParse(medController.text),
                            ),
                          );
                          hive.history.clear();
                          hive.history.addAll(history);
                          hive.frames = int.tryParse(okvirController.text);
                          hive.total = int.tryParse(ukupnoController.text);
                          hive.brood = int.tryParse(legloController.text);
                          hive.honey = int.tryParse(medController.text);
                          hive.save();
                        });
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context)!.saveChanges),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }
}