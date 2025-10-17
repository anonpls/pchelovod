import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRDisplayScreen extends StatelessWidget {
  final String qrData;

  const QRDisplayScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR kod nove košnice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 240.0,
              gapless: false,
            ),
            const SizedBox(height: 20),
            Text('ID: $qrData', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Završi'),
            )
          ],
        ),
      ),
    );
  }
}