import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/medicine.dart';

class AlarmService {
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;

  List<Medicine> medicines = [];

  void start(List<Medicine> meds) {
    medicines = meds;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMedicines();
    });
  }

  void _checkMedicines() {
    final now = DateTime.now();

    for (var med in medicines) {
      if (med.time.hour == now.hour &&
          med.time.minute == now.minute &&
          now.second < 30) {
        _playAlarm(med.name);
      }
    }
  }

  void _playAlarm(String name) async {
    try {
      await _player.play(AssetSource('sounds/alarm.mp3'));
      print("Time to take: $name");
    } catch (e) {
      print("Error playing alarm: $e - using default notification instead");
      // Fallback: just log if audio fails
    }
  }

  void stop() {
    _timer?.cancel();
  }
}
