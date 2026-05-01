import 'package:flutter/material.dart';

class Medicine {
  String id;
  String name;
  String dosage;
  String? medicineFor;
  DateTime startDate;
  TimeOfDay startTime;
  String
      frequency; // 'daily', 'twice_daily', 'thrice_daily', 'every_4h', 'every_6h', 'every_8h', 'custom'
  int? frequencyHours; // For custom frequency
  int durationDays; // How many days to take
  int? totalDoses; // Optional: total number of doses
  int dosesTaken; // Track doses taken
  bool isActive;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    this.medicineFor,
    required this.startDate,
    required this.startTime,
    this.frequency = 'daily',
    this.frequencyHours,
    this.durationDays = 1,
    this.totalDoses,
    this.dosesTaken = 0,
    this.isActive = true,
  });

  // Calculate next alarm time
  DateTime getNextAlarmTime() {
    DateTime nextTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    // If the start time has already passed today, get tomorrow's time
    if (nextTime.isBefore(DateTime.now())) {
      nextTime = nextTime.add(const Duration(days: 1));
    }

    return nextTime;
  }

  // Calculate all alarm times for the day
  List<DateTime> getAlarmTimesForDay(DateTime date) {
    List<DateTime> times = [];

    switch (frequency) {
      case 'daily':
        times.add(DateTime(
            date.year, date.month, date.day, startTime.hour, startTime.minute));
        break;
      case 'twice_daily':
        times.add(DateTime(
            date.year, date.month, date.day, startTime.hour, startTime.minute));
        times.add(DateTime(date.year, date.month, date.day, startTime.hour + 12,
            startTime.minute));
        break;
      case 'thrice_daily':
        times.add(DateTime(
            date.year, date.month, date.day, startTime.hour, startTime.minute));
        times.add(DateTime(date.year, date.month, date.day, startTime.hour + 8,
            startTime.minute));
        times.add(DateTime(date.year, date.month, date.day, startTime.hour + 16,
            startTime.minute));
        break;
      case 'every_4h':
        for (int i = 0; i < 24; i += 4) {
          times.add(DateTime(date.year, date.month, date.day,
              startTime.hour + i, startTime.minute));
        }
        break;
      case 'every_6h':
        for (int i = 0; i < 24; i += 6) {
          times.add(DateTime(date.year, date.month, date.day,
              startTime.hour + i, startTime.minute));
        }
        break;
      case 'every_8h':
        for (int i = 0; i < 24; i += 8) {
          times.add(DateTime(date.year, date.month, date.day,
              startTime.hour + i, startTime.minute));
        }
        break;
      case 'custom':
        if (frequencyHours != null) {
          for (int i = 0; i < 24; i += frequencyHours!) {
            times.add(DateTime(date.year, date.month, date.day,
                startTime.hour + i, startTime.minute));
          }
        }
        break;
    }

    return times;
  }
}
