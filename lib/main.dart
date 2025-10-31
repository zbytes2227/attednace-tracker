import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Attendance',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AttendanceHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
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

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({Key? key}) : super(key: key);

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  List<AttendanceRecord> attendanceRecords = [];
  List<ClassSchedule> timetable = [];
  DateTime selectedDate = DateTime.now();
  DateTime filterMonth = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadTimetable();
    await _loadAttendance();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTimetable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? timetableJson = prefs.getString('timetable');
      if (timetableJson != null && timetableJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(timetableJson);
        if (mounted) {
          setState(() {
            timetable = decoded.map((e) => ClassSchedule.fromJson(e)).toList();
          });
        }
      } else {
        _loadDefaultTimetable();
      }
    } catch (e) {
      debugPrint('Error loading timetable: $e');
      _loadDefaultTimetable();
    }
  }

Future<void> _launchLinkedIn() async {
  final String linkedInUrl =
      'https://www.linkedin.com/in/ujjwal-kushwaha-zbyte/';

  try {
    final Uri url = Uri.parse(linkedInUrl);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Fallback: Try with different launch mode
      try {
        await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
      } catch (e) {
        debugPrint('Error with platformDefault: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open LinkedIn'),
              action: SnackBarAction(
                label: 'Copy Link',
                onPressed: () {
                  // Copy to clipboard functionality
                  Clipboard.setData(
                    ClipboardData(text: linkedInUrl),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    }
  } catch (e) {
    debugPrint('Error launching LinkedIn: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening LinkedIn')),
      );
    }
  }
}


  void _loadDefaultTimetable() {
    timetable = [
      // Monday
      ClassSchedule(
        id: 'mon-1',
        day: 'Monday',
        timeStart: '9:00',
        timeEnd: '10:00',
        subject: 'Mini Project B1',
        code: '311/DAA B2 312',
        type: 'DSM/GK',
      ),
      ClassSchedule(
        id: 'mon-2',
        day: 'Monday',
        timeStart: '10:00',
        timeEnd: '1:00',
        subject: 'Learnovate',
        code: '',
        type: '',
      ),
      ClassSchedule(
        id: 'mon-3',
        day: 'Monday',
        timeStart: '2:00',
        timeEnd: '3:00',
        subject: 'L_WT',
        code: 'PG',
        type: '',
      ),
      ClassSchedule(
        id: 'mon-4',
        day: 'Monday',
        timeStart: '3:00',
        timeEnd: '4:00',
        subject: 'L_COI',
        code: 'MP',
        type: '',
      ),
      ClassSchedule(
        id: 'mon-5',
        day: 'Monday',
        timeStart: '4:00',
        timeEnd: '5:00',
        subject: 'L_DA/OOSD',
        code: 'AK/RS',
        type: '',
      ),

      // Tuesday
      ClassSchedule(
        id: 'tue-1',
        day: 'Tuesday',
        timeStart: '9:00',
        timeEnd: '10:00',
        subject: 'L_COI',
        code: 'MP',
        type: '',
      ),
      ClassSchedule(
        id: 'tue-2',
        day: 'Tuesday',
        timeStart: '10:00',
        timeEnd: '11:00',
        subject: 'L_DAA',
        code: 'GK',
        type: '',
      ),
      ClassSchedule(
        id: 'tue-3',
        day: 'Tuesday',
        timeStart: '11:00',
        timeEnd: '12:00',
        subject: 'L_DA/OOSD',
        code: 'AK/RS',
        type: '',
      ),
      ClassSchedule(
        id: 'tue-4',
        day: 'Tuesday',
        timeStart: '12:00',
        timeEnd: '1:00',
        subject: 'L_WT',
        code: 'PG',
        type: '',
      ),
      ClassSchedule(
        id: 'tue-5',
        day: 'Tuesday',
        timeStart: '2:00',
        timeEnd: '3:00',
        subject: 'L_DBMS',
        code: 'SS',
        type: '',
      ),
      ClassSchedule(
        id: 'tue-6',
        day: 'Tuesday',
        timeStart: '3:00',
        timeEnd: '5:00',
        subject: 'DBMS LAB B1 110/ WT LAB B2 108',
        code: 'SS/PG',
        type: '',
      ),

      // Wednesday
      ClassSchedule(
        id: 'wed-1',
        day: 'Wednesday',
        timeStart: '9:00',
        timeEnd: '10:00',
        subject: 'Mini Project B2',
        code: '110/DAA B1 108',
        type: 'DSM/GK',
      ),
      ClassSchedule(
        id: 'wed-2',
        day: 'Wednesday',
        timeStart: '10:00',
        timeEnd: '11:00',
        subject: 'L_MLT',
        code: 'RS',
        type: '',
      ),
      ClassSchedule(
        id: 'wed-3',
        day: 'Wednesday',
        timeStart: '11:00',
        timeEnd: '12:00',
        subject: 'L_DA/OOSD',
        code: 'AK/RS',
        type: '',
      ),
      ClassSchedule(
        id: 'wed-4',
        day: 'Wednesday',
        timeStart: '2:00',
        timeEnd: '4:00',
        subject: 'Learnovate',
        code: '',
        type: '',
      ),
      ClassSchedule(
        id: 'wed-5',
        day: 'Wednesday',
        timeStart: '4:00',
        timeEnd: '5:00',
        subject: 'NPTEL/LIB',
        code: '',
        type: '',
      ),

      // Thursday
      ClassSchedule(
        id: 'thu-1',
        day: 'Thursday',
        timeStart: '9:00',
        timeEnd: '10:00',
        subject: 'L_DBMS',
        code: 'SS',
        type: '',
      ),
      ClassSchedule(
        id: 'thu-2',
        day: 'Thursday',
        timeStart: '10:00',
        timeEnd: '11:00',
        subject: 'L_WT',
        code: 'PG',
        type: '',
      ),
      ClassSchedule(
        id: 'thu-3',
        day: 'Thursday',
        timeStart: '11:00',
        timeEnd: '12:00',
        subject: 'L_DAA',
        code: 'GK',
        type: '',
      ),
      ClassSchedule(
        id: 'thu-4',
        day: 'Thursday',
        timeStart: '12:00',
        timeEnd: '1:00',
        subject: 'L_DA/OOSD',
        code: 'AK/RS',
        type: '',
      ),
      ClassSchedule(
        id: 'thu-5',
        day: 'Thursday',
        timeStart: '2:00',
        timeEnd: '3:00',
        subject: 'L_DAA',
        code: 'GK',
        type: '',
      ),
      ClassSchedule(
        id: 'thu-6',
        day: 'Thursday',
        timeStart: '3:00',
        timeEnd: '4:00',
        subject: 'L_MLT',
        code: 'RS',
        type: '',
      ),
      ClassSchedule(
        id: 'thu-7',
        day: 'Thursday',
        timeStart: '4:00',
        timeEnd: '5:00',
        subject: 'L_DBMS',
        code: 'SS',
        type: '',
      ),

      // Friday
      ClassSchedule(
        id: 'fri-1',
        day: 'Friday',
        timeStart: '9:00',
        timeEnd: '11:00',
        subject: 'DBMS LAB B2 108/ WT LAB B1 110',
        code: 'SS/PG',
        type: '',
      ),
      ClassSchedule(
        id: 'fri-2',
        day: 'Friday',
        timeStart: '11:00',
        timeEnd: '1:00',
        subject: 'Learnovate',
        code: '',
        type: '',
      ),
      ClassSchedule(
        id: 'fri-3',
        day: 'Friday',
        timeStart: '2:00',
        timeEnd: '3:00',
        subject: 'L_MLT',
        code: 'RS',
        type: '',
      ),
      ClassSchedule(
        id: 'fri-4',
        day: 'Friday',
        timeStart: '3:00',
        timeEnd: '4:00',
        subject: 'L_DAA',
        code: 'GK',
        type: '',
      ),
      ClassSchedule(
        id: 'fri-5',
        day: 'Friday',
        timeStart: '4:00',
        timeEnd: '5:00',
        subject: 'L_DA/OOSD',
        code: 'AK/RS',
        type: '',
      ),
    ];
    _saveTimetable();
  }

  Future<void> _saveTimetable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        timetable.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('timetable', encoded);
    } catch (e) {
      debugPrint('Error saving timetable: $e');
    }
  }

  Future<void> _loadAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? attendanceJson = prefs.getString('attendance_records');
      if (attendanceJson != null && attendanceJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(attendanceJson);
        if (mounted) {
          setState(() {
            attendanceRecords = decoded
                .map((e) => AttendanceRecord.fromJson(e))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  Future<void> _saveAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        attendanceRecords.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('attendance_records', encoded);
    } catch (e) {
      debugPrint('Error saving attendance: $e');
    }
  }

  void _toggleAttendance(ClassSchedule classItem, bool attended) {
    setState(() {
      attendanceRecords.removeWhere(
        (record) =>
            record.classId == classItem.uniqueId &&
            DateFormat('yyyy-MM-dd').format(record.date) ==
                DateFormat('yyyy-MM-dd').format(selectedDate),
      );

      attendanceRecords.add(
        AttendanceRecord(
          classId: classItem.uniqueId,
          date: selectedDate,
          attended: attended,
        ),
      );
    });

    _saveAttendance();
  }

  bool? _getAttendanceStatus(ClassSchedule classItem) {
    try {
      final record = attendanceRecords.firstWhere(
        (record) =>
            record.classId == classItem.uniqueId &&
            DateFormat('yyyy-MM-dd').format(record.date) ==
                DateFormat('yyyy-MM-dd').format(selectedDate),
        orElse: () => AttendanceRecord(
          classId: '',
          date: DateTime.now(),
          attended: false,
        ),
      );
      return record.classId.isEmpty ? null : record.attended;
    } catch (e) {
      return null;
    }
  }

  List<ClassSchedule> _getTodayClasses() {
    try {
      final dayName = DateFormat('EEEE').format(selectedDate);
      return timetable.where((c) => c.day == dayName).toList()
        ..sort((a, b) => a.timeStart.compareTo(b.timeStart));
    } catch (e) {
      return [];
    }
  }

  List<AttendanceRecord> _getFilteredRecords() {
    try {
      return attendanceRecords.where((record) {
        return record.date.year == filterMonth.year &&
            record.date.month == filterMonth.month;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, int> _getSubjectStats() {
    Map<String, int> stats = {};
    try {
      for (var record in _getFilteredRecords()) {
        if (record.attended) {
          final classItem = timetable.firstWhere(
            (c) => c.uniqueId == record.classId,
            orElse: () => ClassSchedule(
              id: '',
              day: '',
              timeStart: '',
              timeEnd: '',
              subject: '',
              code: '',
              type: '',
            ),
          );
          if (classItem.subject.isNotEmpty) {
            final subject = classItem.subject;
            stats[subject] = (stats[subject] ?? 0) + 1;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting subject stats: $e');
    }
    return stats;
  }

  Map<String, int> _getWeeklyStats() {
    Map<String, int> weeklyStats = {};
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      for (var record in attendanceRecords) {
        if (record.attended &&
            record.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            record.date.isBefore(weekEnd.add(const Duration(days: 1)))) {
          final classItem = timetable.firstWhere(
            (c) => c.uniqueId == record.classId,
            orElse: () => ClassSchedule(
              id: '',
              day: '',
              timeStart: '',
              timeEnd: '',
              subject: '',
              code: '',
              type: '',
            ),
          );
          if (classItem.subject.isNotEmpty) {
            final subject = classItem.subject;
            weeklyStats[subject] = (weeklyStats[subject] ?? 0) + 1;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting weekly stats: $e');
    }
    return weeklyStats;
  }

  int _getTotalAttended() {
    try {
      return _getFilteredRecords().where((r) => r.attended).length;
    } catch (e) {
      return 0;
    }
  }

  int _getTotalSkipped() {
    try {
      return _getFilteredRecords().where((r) => !r.attended).length;
    } catch (e) {
      return 0;
    }
  }

  void _showTimetableEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableEditorPage(
          timetable: timetable,
          onSave: (updatedTimetable) {
            setState(() {
              timetable = updatedTimetable;
            });
            _saveTimetable();
          },
        ),
      ),
    );
  }

  void _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: filterMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && mounted) {
      setState(() {
        filterMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final todayClasses = _getTodayClasses();
    final subjectStats = _getSubjectStats();
    final weeklyStats = _getWeeklyStats();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Edit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Attendance',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEEE, MMMM d, y').format(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showTimetableEditor,
                      icon: const Icon(Icons.edit_calendar),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.all(12),
                      ),
                      tooltip: 'Edit Timetable',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date Selector
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            setState(() {
                              selectedDate = selectedDate.subtract(
                                const Duration(days: 1),
                              );
                            });
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              DateFormat('EEE, MMM d').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            setState(() {
                              selectedDate = selectedDate.add(
                                const Duration(days: 1),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Today's Classes
                Text(
                  'Today\'s Classes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 12),

                todayClasses.isEmpty
                    ? Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No classes today!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayClasses.length,
                        itemBuilder: (context, index) {
                          final classItem = todayClasses[index];
                          final attendanceStatus = _getAttendanceStatus(
                            classItem,
                          );

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: attendanceStatus == true
                                    ? Colors.green.shade300
                                    : attendanceStatus == false
                                    ? Colors.red.shade300
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          classItem.time,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (attendanceStatus != null)
                                        Icon(
                                          attendanceStatus
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: attendanceStatus
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    classItem.subject,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (classItem.code.isNotEmpty)
                                    Text(
                                      '${classItem.code} ${classItem.type}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _toggleAttendance(
                                            classItem,
                                            true,
                                          ),
                                          icon: const Icon(
                                            Icons.check,
                                            size: 18,
                                          ),
                                          label: const Text('Attended'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                attendanceStatus == true
                                                ? Colors.green
                                                : Colors.grey.shade300,
                                            foregroundColor:
                                                attendanceStatus == true
                                                ? Colors.white
                                                : Colors.black87,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _toggleAttendance(
                                            classItem,
                                            false,
                                          ),
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          label: const Text('Skipped'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                attendanceStatus == false
                                                ? Colors.red
                                                : Colors.grey.shade300,
                                            foregroundColor:
                                                attendanceStatus == false
                                                ? Colors.white
                                                : Colors.black87,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 30),

                // Insights Section with Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showMonthPicker,
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: Text(DateFormat('MMM yyyy').format(filterMonth)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Overall Stats
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getTotalAttended()}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Attended',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getTotalSkipped()}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Skipped',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // This Week Stats
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'This Week',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        weeklyStats.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'No classes attended this week',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: weeklyStats.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: LinearProgressIndicator(
                                            value: (entry.value / 10).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.blue.shade600,
                                                ),
                                            minHeight: 8,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 30,
                                          child: Text(
                                            '${entry.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Monthly Subject Stats
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bar_chart,
                              color: Colors.purple.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${DateFormat('MMMM').format(filterMonth)} Stats',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        subjectStats.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'No classes attended in this month',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: subjectStats.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: LinearProgressIndicator(
                                            value: (entry.value / 20).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.purple.shade600,
                                                ),
                                            minHeight: 8,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 30,
                                          child: Text(
                                            '${entry.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                                Center(
                  child: Column(
                    children: [
                      const Divider(thickness: 2),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _launchLinkedIn,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            'Made by Ujjwal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '© 2025 Zbytes Attendance Tracker',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Timetable Editor Page
class TimetableEditorPage extends StatefulWidget {
  final List<ClassSchedule> timetable;
  final Function(List<ClassSchedule>) onSave;

  const TimetableEditorPage({
    Key? key,
    required this.timetable,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TimetableEditorPage> createState() => _TimetableEditorPageState();
}

class _TimetableEditorPageState extends State<TimetableEditorPage> {
  late List<ClassSchedule> editableTimetable;
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    editableTimetable = List.from(widget.timetable);
  }

  void _addClass(String day) {
    showDialog(
      context: context,
      builder: (context) => AddEditClassDialog(
        day: day,
        onSave: (newClass) {
          setState(() {
            editableTimetable.add(newClass);
          });
        },
      ),
    );
  }

  void _editClass(ClassSchedule classItem) {
    showDialog(
      context: context,
      builder: (context) => AddEditClassDialog(
        day: classItem.day,
        existingClass: classItem,
        onSave: (updatedClass) {
          setState(() {
            final index = editableTimetable.indexWhere(
              (c) => c.uniqueId == classItem.uniqueId,
            );
            if (index != -1) {
              editableTimetable[index] = updatedClass;
            }
          });
        },
      ),
    );
  }

  void _deleteClass(ClassSchedule classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Delete ${classItem.subject}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                editableTimetable.removeWhere(
                  (c) => c.uniqueId == classItem.uniqueId,
                );
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<ClassSchedule> _getClassesForDay(String day) {
    return editableTimetable.where((c) => c.day == day).toList()
      ..sort((a, b) => a.timeStart.compareTo(b.timeStart));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timetable'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              widget.onSave(editableTimetable);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final dayClasses = _getClassesForDay(day);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _addClass(day),
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (dayClasses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No classes',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ...dayClasses.map((classItem) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.blue.shade50,
                        child: ListTile(
                          title: Text(
                            classItem.subject,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${classItem.time}${classItem.code.isNotEmpty ? '\n${classItem.code} ${classItem.type}' : ''}',
                          ),
                          isThreeLine: classItem.code.isNotEmpty,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editClass(classItem),
                                color: Colors.blue.shade700,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteClass(classItem),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Add/Edit Class Dialog
class AddEditClassDialog extends StatefulWidget {
  final String day;
  final ClassSchedule? existingClass;
  final Function(ClassSchedule) onSave;

  const AddEditClassDialog({
    Key? key,
    required this.day,
    this.existingClass,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditClassDialog> createState() => _AddEditClassDialogState();
}

class _AddEditClassDialogState extends State<AddEditClassDialog> {
  late TextEditingController subjectController;
  late TextEditingController codeController;
  late TextEditingController typeController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  @override
  void initState() {
    super.initState();
    subjectController = TextEditingController(
      text: widget.existingClass?.subject ?? '',
    );
    codeController = TextEditingController(
      text: widget.existingClass?.code ?? '',
    );
    typeController = TextEditingController(
      text: widget.existingClass?.type ?? '',
    );
    startTimeController = TextEditingController(
      text: widget.existingClass?.timeStart ?? '9:00',
    );
    endTimeController = TextEditingController(
      text: widget.existingClass?.timeEnd ?? '10:00',
    );
  }

  @override
  void dispose() {
    subjectController.dispose();
    codeController.dispose();
    typeController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void _save() {
    if (subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subject is required')));
      return;
    }

    final newClass = ClassSchedule(
      id:
          widget.existingClass?.id ??
          '${widget.day.toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}',
      day: widget.day,
      timeStart: startTimeController.text.trim(),
      timeEnd: endTimeController.text.trim(),
      subject: subjectController.text.trim(),
      code: codeController.text.trim(),
      type: typeController.text.trim(),
    );

    widget.onSave(newClass);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingClass == null ? 'Add Class' : 'Edit Class'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject Name*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                      hintText: '9:00',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                      hintText: '10:00',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Code (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
