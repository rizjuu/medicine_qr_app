import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanQR extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onScanned;

  const ScanQR({super.key, required this.onScanned});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  late MobileScannerController controller;
  bool _flashEnabled = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _permissionGranted = status.isGranted;
    });

    if (!status.isGranted) {
      if (mounted) {
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to scan QR codes'),
              duration: Duration(seconds: 3),
              backgroundColor: Color(0xFFF44336),
            ),
          );
        } else if (status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Camera permission is permanently denied. Open settings to enable.'),
              duration: Duration(seconds: 3),
              backgroundColor: Color(0xFFF44336),
            ),
          );
          openAppSettings();
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionGranted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan Medicine QR'),
          backgroundColor: const Color(0xFF2E7D32),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Camera Permission Denied',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Allow camera access to scan QR codes',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('Request Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan Medicine QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _flashEnabled ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: () async {
                await controller.toggleTorch();
                setState(() {
                  _flashEnabled = !_flashEnabled;
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;

              print('Barcodes detected: ${barcodes.length}');

              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                print('Barcode raw value: $rawValue');
                print('Barcode format: ${barcode.format}');

                if (rawValue != null && rawValue.isNotEmpty) {
                  try {
                    // Try to parse as JSON first
                    try {
                      final data = jsonDecode(rawValue);
                      if (data is Map &&
                          data.containsKey('name') &&
                          data.containsKey('dosage') &&
                          data.containsKey('for')) {
                        print('Valid JSON QR detected');
                        await widget.onScanned(Map<String, dynamic>.from(data));
                        if (mounted) {
                          Navigator.pop(context);
                        }
                        return;
                      }
                    } catch (jsonError) {
                      print('JSON parse error: $jsonError');
                    }

                    // If not valid JSON, show error
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Invalid format.\nExpected JSON with: name, dosage, for\nScanned: $rawValue',
                          ),
                          duration: const Duration(seconds: 3),
                          backgroundColor: const Color(0xFFF44336),
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error processing barcode: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFFF44336),
                        ),
                      );
                    }
                  }
                }
              }
            },
          ),
          // Scanning frame overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dark overlay with transparent center
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  // Transparent QR scanning frame
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0066CC),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // Corner decorations
                  Container(
                    width: 280,
                    height: 280,
                    child: Stack(
                      children: [
                        // Top-left corner
                        Positioned(
                          top: -4,
                          left: -4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                                left: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        // Top-right corner
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                                right: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-left corner
                        Positioned(
                          bottom: -4,
                          left: -4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                                left: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-right corner
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                                right: BorderSide(
                                  color: const Color(0xFF0066CC),
                                  width: 4,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom instructions panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Align QR Code in Frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Position the QR code clearly within the frame for accurate scanning',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ensure good lighting for best results',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Test button to verify scanner
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Test with sample QR data
                          final testData = {
                            'name': 'Test Medicine',
                            'dosage': '500mg',
                            'for': 'Test Purpose',
                          };
                          widget.onScanned(testData);
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Text(
                            'Test Scanner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
