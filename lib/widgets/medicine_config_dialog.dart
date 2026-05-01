import 'package:flutter/material.dart';
import '../models/medicine.dart';

class MedicineConfigDialog extends StatefulWidget {
  final Map<String, dynamic> medicineData;

  const MedicineConfigDialog({
    super.key,
    required this.medicineData,
  });

  @override
  State<MedicineConfigDialog> createState() => _MedicineConfigDialogState();
}

class _MedicineConfigDialogState extends State<MedicineConfigDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _frequency;
  late int _durationDays;
  late int? _frequencyHours;
  late int? _totalDoses;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _frequency = 'daily';
    _durationDays = 7;
    _frequencyHours = null;
    _totalDoses = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveMedicine() {
    final medicine = Medicine(
      id: DateTime.now().toString(),
      name: widget.medicineData['name'],
      dosage: widget.medicineData['dosage'],
      medicineFor: widget.medicineData['for'],
      startDate: _selectedDate,
      startTime: _selectedTime,
      frequency: _frequency,
      frequencyHours: _frequencyHours,
      durationDays: _durationDays,
      totalDoses: _totalDoses,
    );

    Navigator.pop(context, medicine);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Medicine Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine info display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.medicineData['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosage: ${widget.medicineData['dosage']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Start Date
            const Text('Start Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Start Time
            const Text('Start Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(Icons.access_time, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Frequency
            const Text('How Often',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _frequency,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Once a day')),
                DropdownMenuItem(
                    value: 'twice_daily', child: Text('Twice a day')),
                DropdownMenuItem(
                    value: 'thrice_daily', child: Text('Three times a day')),
                DropdownMenuItem(
                    value: 'every_4h', child: Text('Every 4 hours')),
                DropdownMenuItem(
                    value: 'every_6h', child: Text('Every 6 hours')),
                DropdownMenuItem(
                    value: 'every_8h', child: Text('Every 8 hours')),
                DropdownMenuItem(value: 'custom', child: Text('Custom hours')),
              ],
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            // Custom frequency (if selected)
            if (_frequency == 'custom')
              Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Every X hours',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _frequencyHours = int.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            // Duration Days
            const Text('Duration (Days)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Slider(
              value: _durationDays.toDouble(),
              min: 1,
              max: 90,
              divisions: 89,
              label: '$_durationDays days',
              onChanged: (value) {
                setState(() {
                  _durationDays = value.toInt();
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Total duration: $_durationDays days',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Total Doses (optional)
            const Text('Total Doses (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Leave empty for unlimited',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _totalDoses = int.tryParse(value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          onPressed: _saveMedicine,
          child: const Text('Add Medicine'),
        ),
      ],
    );
  }
}
