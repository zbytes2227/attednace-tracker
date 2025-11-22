// models for attendmitra
class Subject {
  final String name;
  final String code;
  final String teacher;

  Subject({
    required this.name,
    required this.code,
    required this.teacher,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'teacher': teacher,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        teacher: json['teacher'] ?? '',
      );
}

class ClassSchedule {
  final String id;
  final String day;
  final String timeStart;
  final String timeEnd;
  final String subject;
  final String code;
  final String type;

  ClassSchedule({
    required this.id,
    required this.day,
    required this.timeStart,
    required this.timeEnd,
    required this.subject,
    required this.code,
    required this.type,
  });

  String get time => '$timeStart-$timeEnd';
  String get uniqueId => id;

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'subject': subject,
        'code': code,
        'type': type,
      };

  factory ClassSchedule.fromJson(Map<String, dynamic> json) => ClassSchedule(
        id: json['id'] ?? '',
        day: json['day'] ?? '',
        timeStart: json['timeStart'] ?? '',
        timeEnd: json['timeEnd'] ?? '',
        subject: json['subject'] ?? '',
        code: json['code'] ?? '',
        type: json['type'] ?? '',
      );
}

class AttendanceRecord {
  final String classId;
  final DateTime date;
  final bool attended;

  AttendanceRecord({
    required this.classId,
    required this.date,
    required this.attended,
  });

  Map<String, dynamic> toJson() => {
        'classId': classId,
        'date': date.toIso8601String(),
        'attended': attended,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        classId: json['classId'] ?? '',
        date: DateTime.parse(json['date']),
        attended: json['attended'] ?? false,
      );
}
