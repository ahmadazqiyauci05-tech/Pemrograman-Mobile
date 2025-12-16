class ActivityModel {
  final String name;
  final String category;
  final int durationHours;
  final bool isDone;
  final String? notes;

  ActivityModel({
    required this.name,
    required this.category,
    required this.durationHours,
    required this.isDone,
    this.notes,
  });
}
