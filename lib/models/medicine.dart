class Medicine {
  String id;
  String name;
  String dosage;
  String? medicineFor;
  DateTime time;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    this.medicineFor,
    required this.time,
  });
}
