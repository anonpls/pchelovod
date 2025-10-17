import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kosnice_app/models/hive_entry.dart';

class ShowQRCodeScreen extends StatelessWidget {
  final HiveEntry hive;

  const ShowQRCodeScreen({super.key, required this.hive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR kod nove košnice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: hive.id,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text('ID: ${hive.id}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nazad'),
            )
          ],
        ),
      ),
    );
  }
}