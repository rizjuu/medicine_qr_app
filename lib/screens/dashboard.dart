import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../screens/scan_qr.dart';
import '../services/alarm_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Medicine> medicines = [];
  final AlarmService alarmService = AlarmService();

  void _addMedicine(Map<String, dynamic> data) {
    final med = Medicine(
      id: DateTime.now().toString(),
      name: data['name'],
      dosage: data['dosage'],
      medicineFor: data['for'],
      time: DateTime.now().add(const Duration(minutes: 1)),
    );

    setState(() {
      medicines.add(med);
    });

    alarmService.start(medicines);
  }

  void _updateTime(Medicine med, TimeOfDay time) {
    setState(() {
      med.time = DateTime(
        med.time.year,
        med.time.month,
        med.time.day,
        time.hour,
        time.minute,
      );
    });

    alarmService.start(medicines);
  }

  void _deleteMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });
    alarmService.start(medicines);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    alarmService.start(medicines);
  }

  @override
  void dispose() {
    alarmService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicine Dashboard")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ScanQR(onScanned: _addMedicine)),
          );
        },
      ),
      body: ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final med = medicines[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                med.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${med.dosage}\n${med.medicineFor ?? 'No description'}\nTime: ${_formatTime(med.time)}",
                style: const TextStyle(fontSize: 13),
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(med.time),
                        );
                        if (picked != null) {
                          _updateTime(med, picked);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMedicine(index),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
