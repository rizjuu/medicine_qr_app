import 'package:flutter/material.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const MedicineApp());
}

class MedicineApp extends StatelessWidget {
  const MedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine QR App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Dashboard(),
    );
  }
}