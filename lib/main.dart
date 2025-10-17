import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kosnice_app/models/hive_entry.dart';
import 'package:kosnice_app/models/hive_check_entry.dart';
import 'package:kosnice_app/screens/hive_list_screen.dart';
import 'package:kosnice_app/screens/hive_detail_screen.dart';
import 'package:kosnice_app/screens/add_hive_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kosnice_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(HiveEntryAdapter());
  Hive.registerAdapter(HiveCheckEntryAdapter());

  // Always open the box, regardless of whether it's open
  await Hive.openBox<HiveEntry>('hives');

  await _createAutomaticBackup();

  runApp(const KosniceApp());
}

class KosniceApp extends StatefulWidget {
  const KosniceApp({super.key});

  @override
  State<KosniceApp> createState() => _KosniceAppState();
}

class _KosniceAppState extends State<KosniceApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLocale();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  void _toggleTheme() {
    final isDark = _themeMode == ThemeMode.light;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    _saveTheme(isDark);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('locale');
    if (langCode != null) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
  }

  void _changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
    _saveLocale(newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kosnice App',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      locale: _locale ?? const Locale('sr'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('sr'),
        Locale('en'),
        Locale('ru'),
      ],
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        onChangeLanguage: _changeLanguage,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final void Function(Locale) onChangeLanguage;
  const HomeScreen({super.key, required this.onToggleTheme, required this.onChangeLanguage});

  Future<void> _exportAllData(BuildContext context) async {
    final box = Hive.box<HiveEntry>('hives');
    final entries = box.values.toList();

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nema podataka za eksport.')),
      );
      return;
    }

    final csvContent = StringBuffer();
    csvContent.writeln('ID;Naziv;Opis;Tip;Broj zabeleški');
    for (final hive in entries) {
      csvContent.writeln('${hive.id};${hive.name ?? ""};${hive.description ?? ""};${hive.type};${hive.notes.length}');
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/kosnice_export.csv');
      await file.writeAsString(csvContent.toString());

      await Share.shareXFiles([XFile(file.path)], text: 'Eksportovana CSV lista košnica');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška pri eksportovanju CSV-a.')),
      );
    }
  }

  Future<void> _exportForOtherDevice(BuildContext context) async {
    final box = Hive.box<HiveEntry>('hives');
    final entries = box.values.toList();

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nema podataka za eksport.')),
      );
      return;
    }

    final data = entries.map((e) => {
      'id': e.id,
      'name': e.name,
      'description': e.description,
      'type': e.type,
      'notes': e.notes,
      'imagePaths': e.imagePaths,
      'tags': e.tags,
      'breed': e.breed,
      'queenPresent': e.queenPresent,
    }).toList();

    final jsonString = jsonEncode(data);

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/kosnice_export.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup podataka za drugi uređaj',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška pri eksportovanju JSON fajla.')),
      );
    }
  }

  Future<void> _importFromOtherDevice(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.first.path!);
    final jsonStr = await file.readAsString();

    try {
      final List<dynamic> data = jsonDecode(jsonStr);
      final box = Hive.box<HiveEntry>('hives');

      for (var entry in data) {
        final hive = HiveEntry(
          id: entry['id'],
          name: entry['name'],
          description: entry['description'],
          type: entry['type'],
          history: entry['history'] ?? [],
          breed: entry['breed'],
          queenPresent: entry['queenPresent'],
        );
        hive.notes.addAll(List<String>.from(entry['notes'] ?? []));
        hive.imagePaths.addAll(List<String>.from(entry['imagePaths'] ?? []));
        hive.tags.addAll(List<String>.from(entry['tags'] ?? []));
        await box.add(hive);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import uspešan!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška pri importovanju podataka.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: onChangeLanguage,
            itemBuilder: (context) => [
              const PopupMenuItem(value: Locale('sr'), child: Text('Srpski')),
              const PopupMenuItem(value: Locale('en'), child: Text('English')),
              const PopupMenuItem(value: Locale('ru'), child: Text('Русский')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            HomeButton(
              text: '1. ${AppLocalizations.of(context)!.scanQR}',
              icon: Icons.qr_code_scanner,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScannerScreen()),
                ).then((result) {
                  if (result != null && result is HiveEntry && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HiveDetailScreen(
                          hive: HiveEntry(
                            id: result.id,
                            name: result.name,
                            description: result.description,
                            type: result.type,
                            tags: result.tags,
                            notes: result.notes,
                            imagePaths: result.imagePaths,
                            latitude: result.latitude,
                            longitude: result.longitude,
                            frames: result.frames,
                            total: result.total,
                            brood: result.brood,
                            honey: result.honey,
                            history: result.history,
                            breed: result.breed,
                            queenPresent: result.queenPresent,
                          ),
                          history: result.history,
                        ),
                      ),
                    );
                  }
                });
              },
            ),
            HomeButton(
              text: '2. ${AppLocalizations.of(context)!.addHive}',
              icon: Icons.add_box_outlined,
              onTap: () async {
                final newId = DateTime.now().millisecondsSinceEpoch.toString();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddHiveScreen(hiveId: newId),
                  ),
                );
              },
            ),
            HomeButton(
              text: '3. ${AppLocalizations.of(context)!.viewHives}',
              icon: Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HiveListScreen()),
                );
              },
            ),
            HomeButton(
              text: '4. Import/Export',
              icon: Icons.swap_vert_circle_outlined,
              onTap: () async {
                if (!context.mounted) return;
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (ctx) {
                    return SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.file_download),
                            title: Text(AppLocalizations.of(context)!.exportAllData),
                            onTap: () {
                              Navigator.pop(ctx);
                              _exportAllData(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.ios_share),
                            title: Text(AppLocalizations.of(context)!.exportForOtherDevice),
                            onTap: () {
                              Navigator.pop(ctx);
                              _exportForOtherDevice(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.file_upload),
                            title: Text(AppLocalizations.of(context)!.importFromOtherDevice),
                            onTap: () {
                              Navigator.pop(ctx);
                              _importFromOtherDevice(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Uklonjeno dugme "Idi na detalje košnice"
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const HomeButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, size: 32),
        title: Text(text, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.scanQR)),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            final id = barcode.rawValue!.trim();
            final box = Hive.box<HiveEntry>('hives');
            final match = box.values.cast<HiveEntry?>().firstWhere(
              (hive) => hive?.id == id,
              orElse: () => null,
            );

            if (match != null) {
              Navigator.pop(context, match);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Košnica sa tim ID-jem nije pronađena.')),
              );
            }
          }
        },
      ),
    );
  }
}

// Moved out of class, to the end of the file
Future<void> _createAutomaticBackup() async {
  final box = Hive.box<HiveEntry>('hives');
  final entries = box.values.toList();

  if (entries.isEmpty) return;

  final data = entries.map((e) => {
    'id': e.id,
    'name': e.name,
    'description': e.description,
    'type': e.type,
    'notes': e.notes,
    'imagePaths': e.imagePaths,
    'tags': e.tags,
    'history': e.history.map((h) => h.toString()).toList(),
  }).toList();

  final jsonString = jsonEncode(data);

  try {
    final dir = await getApplicationDocumentsDirectory();
    final backupFile = File('${dir.path}/autosave_kosnice.json');
    await backupFile.writeAsString(jsonString);
  } catch (e) {
    // Ako hoćeš možeš ovde logovati grešku
  }
}