import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/medicine.dart';

class AlarmService {
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;
  Function(Medicine)? onAlarmTriggered;

  List<Medicine> medicines = [];
  final Set<String> _triggeredAlarms = {};

  void start(List<Medicine> meds) {
    medicines = meds;
    _triggeredAlarms.clear();

    _timer?.cancel();
    // Check every 1 second for accurate timing
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkMedicines();
    });
  }

  void _checkMedicines() {
    final now = DateTime.now();

    for (var med in medicines) {
      if (!med.isActive) continue;

      // Check if we're within the medicine's active duration
      final medicineEndDate =
          med.startDate.add(Duration(days: med.durationDays));
      if (now.isBefore(med.startDate) || now.isAfter(medicineEndDate)) {
        continue;
      }

      // Get all alarm times for today
      final alarmTimes = med.getAlarmTimesForDay(now);

      for (var alarmTime in alarmTimes) {
        // Create a unique ID for this alarm
        final alarmId =
            '${med.id}_${alarmTime.hour}_${alarmTime.minute}_${now.day}';

        // Check if this alarm time matches current time (within first 3 seconds of the minute)
        final isTimeMatch = alarmTime.hour == now.hour &&
            alarmTime.minute == now.minute &&
            (now.second >= 0 && now.second < 3);

        if (isTimeMatch && !_triggeredAlarms.contains(alarmId)) {
          _triggeredAlarms.add(alarmId);
          _playAlarm(med);
          onAlarmTriggered?.call(med);
          med.dosesTaken++;
          print(
              'Alarm triggered for: ${med.name} - Dose ${med.dosesTaken}/${med.totalDoses ?? '∞'}');
        }
      }
    }
  }

  void _playAlarm(Medicine med) async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/alarmz.mp3'));
      print("Alarm triggered for: ${med.name}");
    } catch (e) {
      print("Error playing alarm: $e - using default notification instead");
    }
  }

  Future<void> stopAlarm() async {
    try {
      await _player.stop();
      print("Alarm stopped");
    } catch (e) {
      print("Error stopping alarm: $e");
    }
  }

  void stop() {
    _timer?.cancel();
    _player.stop();
    _triggeredAlarms.clear();
  }

  void dispose() {
    stop();
    _player.dispose();
  }
}
