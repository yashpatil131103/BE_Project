class Task {
  int? id;
  String taskDescription;
  DateTime startTime;
  DateTime endTime;
  bool isCompleted;

  Task({
    this.id,
    required this.taskDescription,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  });

  // Convert Task to Map for SQFlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskDescription': taskDescription,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Convert Map to Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      taskDescription: map['taskDescription'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
