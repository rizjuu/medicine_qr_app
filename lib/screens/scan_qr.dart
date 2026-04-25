import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatelessWidget {
  final Function(Map<String, dynamic>) onScanned;

  const ScanQR({super.key, required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Medicine QR")),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              try {
                final data = jsonDecode(barcode.rawValue!);
                if (data is Map &&
                    data.containsKey('name') &&
                    data.containsKey('dosage') &&
                    data.containsKey('for')) {
                  onScanned(Map<String, dynamic>.from(data));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Invalid QR format. Expected: name, dosage, and for.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid QR code')),
                );
              }
            }
          }
        },
      ),
    );
  }
}
