import 'package:flutter/material.dart';
import 'package:kosnice_app/screens/hive_detail_screen.dart';
import 'package:kosnice_app/models/hive_entry.dart';
import 'package:hive/hive.dart';
import 'package:kosnice_app/l10n/app_localizations.dart';
import 'package:kosnice_app/services/auth_service.dart';
import 'package:kosnice_app/services/hive_api_service.dart';

class AddHiveScreen extends StatefulWidget {
  final String hiveId;
  const AddHiveScreen({super.key, required this.hiveId});

  @override
  State<AddHiveScreen> createState() => _AddHiveScreenState();
}

class _AddHiveScreenState extends State<AddHiveScreen> {
  final _authService = AuthService();
  final _hiveApiService = HiveApiService();
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descriptionController = TextEditingController();
  String hiveType = 'LR';


  @override
  void initState() {
    super.initState();
    _idController.text = widget.hiveId;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final hiveId = _idController.text.trim();
      final hive = HiveEntry(
        id: hiveId,
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        description: _descriptionController.text.trim(),
        type: hiveType,
        history: [],
      );

      try {
        final token = await _authService.getToken();
        if (token == null) {
          throw Exception('Необходима авторизация');
        }

        final serverId = await _hiveApiService.createHive(token: token, hive: hive);
        hive.serverId = serverId;

        final box = Hive.box<HiveEntry>('hives');
        await box.put(hiveId, hive);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HiveDetailScreen(hive: hive, history: []),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addNewHiveTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hiveId),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Unesi ID' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hiveName),
              ),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.hiveBreed,
                  hintText: 'npr. krajnka, italijanska...',
                ),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: hiveType,
                items: const [
                  DropdownMenuItem(value: 'LR', child: Text('LR')),
                  DropdownMenuItem(value: 'DB', child: Text('DB')),
                ],
                onChanged: (value) {
                  setState(() {
                    hiveType = value!;
                  });
                },
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hiveType),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(AppLocalizations.of(context)!.continueLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}