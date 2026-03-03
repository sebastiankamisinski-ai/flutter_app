class WorkSession {
  final DateTime startTime;
  final DateTime endTime;

  WorkSession({
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}
