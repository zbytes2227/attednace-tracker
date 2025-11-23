import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'developer_info_page.dart';


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

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({Key? key}) : super(key: key);

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  List<AttendanceRecord> attendanceRecords = [];
  List<ClassSchedule> timetable = [];
  List<Subject> subjects = [];
  DateTime selectedDate = DateTime.now();
  DateTime filterMonth = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadSubjects();
    await _loadTimetable();
    await _loadAttendance();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? subjectsJson = prefs.getString('subjects');
      if (subjectsJson != null && subjectsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(subjectsJson);
        if (mounted) {
          setState(() {
            subjects = decoded.map((e) => Subject.fromJson(e)).toList();
          });
        }
      } else {
        _loadDefaultSubjects();
      }
    } catch (e) {
      debugPrint('Error loading subjects: $e');
      _loadDefaultSubjects();
    }
  }

  void _loadDefaultSubjects() {
    subjects = [
      Subject(name: 'Demo', code: 'BAS3301', teacher: 'Sirname'),
      
    ];
    _saveSubjects();
  }

  Future<void> _saveSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          json.encode(subjects.map((e) => e.toJson()).toList());
      await prefs.setString('subjects', encoded);
    } catch (e) {
      debugPrint('Error saving subjects: $e');
    }
  }

  Future<void> _loadTimetable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? timetableJson = prefs.getString('timetable');
      final bool? hasLoadedBefore = prefs.getBool('has_loaded_timetable');

      if (timetableJson != null && timetableJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(timetableJson);
        if (mounted) {
          setState(() {
            timetable = decoded.map((e) => ClassSchedule.fromJson(e)).toList();
          });
        }
      } else if (hasLoadedBefore == null || !hasLoadedBefore) {
        _loadDefaultTimetable();
        await prefs.setBool('has_loaded_timetable', true);
      }
    } catch (e) {
      debugPrint('Error loading timetable: $e');
    }
  }

  void _loadDefaultTimetable() {
    timetable = [
      // Monday
      
      
    ];
    _saveTimetable();
  }

  Future<void> _saveTimetable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          json.encode(timetable.map((e) => e.toJson()).toList());
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
            attendanceRecords =
                decoded.map((e) => AttendanceRecord.fromJson(e)).toList();
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
      final String encoded =
          json.encode(attendanceRecords.map((e) => e.toJson()).toList());
      await prefs.setString('attendance_records', encoded);
    } catch (e) {
      debugPrint('Error saving attendance: $e');
    }
  }

  Future<void> _launchLinkedIn() async {
    final String linkedInUrl =
        '';

    try {
      final Uri url = Uri.parse(linkedInUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          Clipboard.setData(ClipboardData(text: linkedInUrl));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching LinkedIn: $e');
      if (mounted) {
        Clipboard.setData(ClipboardData(text: linkedInUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      }
    }
  }

  void _toggleAttendance(ClassSchedule classItem, bool attended) {
    setState(() {
      attendanceRecords.removeWhere((record) =>
          record.classId == classItem.uniqueId &&
          DateFormat('yyyy-MM-dd').format(record.date) ==
              DateFormat('yyyy-MM-dd').format(selectedDate));

      attendanceRecords.add(AttendanceRecord(
        classId: classItem.uniqueId,
        date: selectedDate,
        attended: attended,
      ));
    });

    _saveAttendance();

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attended ? 'Marked as Attended ✓' : 'Marked as Skipped ✗'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: attended ? Colors.green : Colors.red,
        ),
      );
    }
  }

  bool? _getAttendanceStatus(ClassSchedule classItem) {
    try {
      final record = attendanceRecords.firstWhere(
        (record) =>
            record.classId == classItem.uniqueId &&
            DateFormat('yyyy-MM-dd').format(record.date) ==
                DateFormat('yyyy-MM-dd').format(selectedDate),
        orElse: () => AttendanceRecord(
            classId: '', date: DateTime.now(), attended: false),
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

  Map<String, int> _getTotalScheduledClasses() {
    Map<String, int> totalClasses = {};
    try {
      final firstDay = DateTime(filterMonth.year, filterMonth.month, 1);
      final lastDay = DateTime(filterMonth.year, filterMonth.month + 1, 0);

      for (DateTime date = firstDay;
          date.isBefore(lastDay.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final dayName = DateFormat('EEEE').format(date);
        final dayClasses = timetable.where((c) => c.day == dayName);

        for (var classItem in dayClasses) {
          totalClasses[classItem.subject] =
              (totalClasses[classItem.subject] ?? 0) + 1;
        }
      }
    } catch (e) {
      debugPrint('Error getting total scheduled classes: $e');
    }
    return totalClasses;
  }

  Map<String, Map<String, int>> _getSubjectStatsWithPercentage() {
    Map<String, Map<String, int>> stats = {};
    try {
      final totalScheduled = _getTotalScheduledClasses();
      final filteredRecords = _getFilteredRecords();

      for (var record in filteredRecords) {
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
                type: ''),
          );
          if (classItem.subject.isNotEmpty) {
            final subject = classItem.subject;
            stats[subject] = {
              'attended': (stats[subject]?['attended'] ?? 0) + 1,
              'total': totalScheduled[subject] ?? 0,
            };
          }
        }
      }

      totalScheduled.forEach((subject, total) {
        if (!stats.containsKey(subject)) {
          stats[subject] = {'attended': 0, 'total': total};
        } else {
          stats[subject]!['total'] = total;
        }
      });
    } catch (e) {
      debugPrint('Error getting subject stats: $e');
    }
    return stats;
  }

  Map<String, Map<String, int>> _getWeeklyStatsWithPercentage() {
    Map<String, Map<String, int>> weeklyStats = {};
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      Map<String, int> totalThisWeek = {};
      for (DateTime date = weekStart;
          date.isBefore(weekEnd.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final dayName = DateFormat('EEEE').format(date);
        final dayClasses = timetable.where((c) => c.day == dayName);

        for (var classItem in dayClasses) {
          totalThisWeek[classItem.subject] =
              (totalThisWeek[classItem.subject] ?? 0) + 1;
        }
      }

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
                type: ''),
          );
          if (classItem.subject.isNotEmpty) {
            final subject = classItem.subject;
            weeklyStats[subject] = {
              'attended': (weeklyStats[subject]?['attended'] ?? 0) + 1,
              'total': totalThisWeek[subject] ?? 0,
            };
          }
        }
      }

      totalThisWeek.forEach((subject, total) {
        if (!weeklyStats.containsKey(subject)) {
          weeklyStats[subject] = {'attended': 0, 'total': total};
        } else {
          weeklyStats[subject]!['total'] = total;
        }
      });
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

  void _showSubjectManager() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectManagerPage(
          subjects: subjects,
          onSave: (updatedSubjects) {
            setState(() {
              subjects = updatedSubjects;
            });
            _saveSubjects();
          },
        ),
      ),
    );
  }

  void _showTimetableEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableEditorPage(
          timetable: timetable,
          subjects: subjects,
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
              colors: [
                const Color.fromARGB(255, 255, 255, 255),
                const Color.fromARGB(255, 255, 255, 255),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final todayClasses = _getTodayClasses();
    final subjectStats = _getSubjectStatsWithPercentage();
    final weeklyStats = _getWeeklyStatsWithPercentage();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 0, 0, 0),
              const Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEEE, MMMM d, y').format(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                            
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _showSubjectManager,
                          icon: const Icon(Icons.list),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 179, 0, 255),
                            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.all(12),
                          ),
                          tooltip: 'Manage Subjects',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _showTimetableEditor,
                          icon: const Icon(Icons.table_view),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.all(12),
                          ),
                          tooltip: 'Edit Timetable',
                        ),
                        IconButton(
  icon: const Icon(Icons.person),
  color: Colors.white,
  tooltip: 'Developer Info',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeveloperInfoPage(),
      ),
    );
  },
),

                      ],
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
                              selectedDate = selectedDate
                                  .subtract(const Duration(days: 1));
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
                              selectedDate =
                                  selectedDate.add(const Duration(days: 1));
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Today's Classes with Swipe
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Classes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    Text(
                      'Swipe ← →',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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
                                Icon(Icons.calendar_month_rounded,
                                    size: 48, color: const Color.fromARGB(255, 0, 0, 0)),
                                const SizedBox(height: 12),
                                Text(
                                  'No classes today!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: const Color.fromARGB(255, 0, 0, 0),
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
                          final attendanceStatus =
                              _getAttendanceStatus(classItem);

                          return Dismissible(
                            key: Key('${classItem.uniqueId}-${selectedDate.toString()}'),
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.white, size: 32),
                                  SizedBox(height: 4),
                                  Text(
                                    'Attended',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel,
                                      color: Colors.white, size: 32),
                                  SizedBox(height: 4),
                                  Text(
                                    'Skipped',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                _toggleAttendance(classItem, true);
                              } else {
                                _toggleAttendance(classItem, false);
                              }
                              return false; // Don't actually dismiss
                            },
                            child: Card(
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 30),

                // Insights Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
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
                                const Color.fromARGB(255, 0, 110, 6),
                                const Color.fromARGB(255, 0, 110, 6)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 32),
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
                                const Color.fromARGB(255, 162, 3, 0),
                                Colors.red.shade600
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.cancel,
                                  color: Color.fromARGB(255, 20, 0, 44), size: 32),
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
                            Icon(Icons.calendar_today,
                                color: Colors.blue.shade700),
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
                                    'No classes scheduled this week',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: weeklyStats.entries.map((entry) {
                                  final attended = entry.value['attended'] ?? 0;
                                  final total = entry.value['total'] ?? 0;
                                  final percentage = total > 0
                                      ? ((attended / total) * 100).round()
                                      : 0;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                entry.key,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '$attended/$total ($percentage%)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: total > 0
                                              ? (attended / total)
                                                  .clamp(0.0, 1.0)
                                              : 0.0,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            percentage >= 75
                                                ? Colors.green
                                                : percentage >= 50
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                          minHeight: 8,
                                          borderRadius:
                                              BorderRadius.circular(10),
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

                // Monthly Stats
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
                            Icon(Icons.bar_chart,
                                color: Colors.purple.shade700),
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
                                    'No classes scheduled this month',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: subjectStats.entries.map((entry) {
                                  final attended = entry.value['attended'] ?? 0;
                                  final total = entry.value['total'] ?? 0;
                                  final percentage = total > 0
                                      ? ((attended / total) * 100).round()
                                      : 0;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                entry.key,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '$attended/$total ($percentage%)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: total > 0
                                              ? (attended / total)
                                                  .clamp(0.0, 1.0)
                                              : 0.0,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            percentage >= 75
                                                ? Colors.green
                                                : percentage >= 50
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                          minHeight: 8,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                const SizedBox(height: 30),

                // Footer
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Subject Manager Page
class SubjectManagerPage extends StatefulWidget {
  final List<Subject> subjects;
  final Function(List<Subject>) onSave;

  const SubjectManagerPage({
    Key? key,
    required this.subjects,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SubjectManagerPage> createState() => _SubjectManagerPageState();
}

class _SubjectManagerPageState extends State<SubjectManagerPage> {
  late List<Subject> editableSubjects;

  @override
  void initState() {
    super.initState();
    editableSubjects = List.from(widget.subjects);
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (context) => AddEditSubjectDialog(
        onSave: (newSubject) {
          setState(() {
            editableSubjects.add(newSubject);
          });
        },
      ),
    );
  }

  void _editSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => AddEditSubjectDialog(
        existingSubject: editableSubjects[index],
        onSave: (updatedSubject) {
          setState(() {
            editableSubjects[index] = updatedSubject;
          });
        },
      ),
    );
  }

  void _deleteSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Delete ${editableSubjects[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                editableSubjects.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manage Subjects'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              widget.onSave(editableSubjects);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, color: Color.fromARGB(255, 255, 255, 255)),
            label: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: editableSubjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.subject, size: 64, color: const Color.fromARGB(255, 0, 0, 0)),
                  const SizedBox(height: 16),
                  Text(
                    'No subjects added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 14, 6, 6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: editableSubjects.length + 1,
              itemBuilder: (context, index) {
                 if (index == editableSubjects.length) {
      return const SizedBox(height: 100);
    }

    
                final subject = editableSubjects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      subject.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${subject.code}${subject.teacher.isNotEmpty ? ' • ${subject.teacher}' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editSubject(index),
                          color: Colors.blue.shade700,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteSubject(index),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubject,
        backgroundColor: Colors.purple.shade700,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }
}

// Add/Edit Subject Dialog
class AddEditSubjectDialog extends StatefulWidget {
  final Subject? existingSubject;
  final Function(Subject) onSave;

  const AddEditSubjectDialog({
    Key? key,
    this.existingSubject,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditSubjectDialog> createState() => _AddEditSubjectDialogState();
}

class _AddEditSubjectDialogState extends State<AddEditSubjectDialog> {
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController teacherController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.existingSubject?.name ?? '');
    codeController =
        TextEditingController(text: widget.existingSubject?.code ?? '');
    teacherController =
        TextEditingController(text: widget.existingSubject?.teacher ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    teacherController.dispose();
    super.dispose();
  }

  void _save() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject name is required')),
      );
      return;
    }

    final newSubject = Subject(
      name: nameController.text.trim(),
      code: codeController.text.trim(),
      teacher: teacherController.text.trim(),
    );

    widget.onSave(newSubject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existingSubject == null ? 'Add Subject' : 'Edit Subject'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Subject Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: teacherController,
              decoration: const InputDecoration(
                labelText: 'Teacher Name',
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
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Timetable Editor Page
class TimetableEditorPage extends StatefulWidget {
  final List<ClassSchedule> timetable;
  final List<Subject> subjects;
  final Function(List<ClassSchedule>) onSave;

  const TimetableEditorPage({
    Key? key,
    required this.timetable,
    required this.subjects,
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
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    editableTimetable = List.from(widget.timetable);
  }

  void _addClass(String day) {
    if (widget.subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add subjects first before creating timetable'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddEditClassDialog(
        day: day,
        subjects: widget.subjects,
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
        subjects: widget.subjects,
        existingClass: classItem,
        onSave: (updatedClass) {
          setState(() {
            final index = editableTimetable
                .indexWhere((c) => c.uniqueId == classItem.uniqueId);
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
                editableTimetable
                    .removeWhere((c) => c.uniqueId == classItem.uniqueId);
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
       backgroundColor: Colors.black,
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
            label: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
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
                        icon: const Icon(Icons.add_circle_rounded, size:40),
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
  final List<Subject> subjects;
  final ClassSchedule? existingClass;
  final Function(ClassSchedule) onSave;

  const AddEditClassDialog({
    Key? key,
    required this.day,
    required this.subjects,
    this.existingClass,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditClassDialog> createState() => _AddEditClassDialogState();
}

class _AddEditClassDialogState extends State<AddEditClassDialog> {
  Subject? selectedSubject;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  @override
  void initState() {
    super.initState();

    if (widget.existingClass != null) {
      selectedSubject = widget.subjects.firstWhere(
        (s) => s.name == widget.existingClass!.subject,
        orElse: () => widget.subjects.isNotEmpty
            ? widget.subjects[0]
            : Subject(name: '', code: '', teacher: ''),
      );
    } else if (widget.subjects.isNotEmpty) {
      selectedSubject = widget.subjects[0];
    }

    startTimeController = TextEditingController(
        text: widget.existingClass?.timeStart ?? '9:00');
    endTimeController =
        TextEditingController(text: widget.existingClass?.timeEnd ?? '10:00');
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void _save() {
    if (selectedSubject == null || selectedSubject!.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    final newClass = ClassSchedule(
      id: widget.existingClass?.id ??
          '${widget.day.toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}',
      day: widget.day,
      timeStart: startTimeController.text.trim(),
      timeEnd: endTimeController.text.trim(),
      subject: selectedSubject!.name,
      code: selectedSubject!.code,
      type: selectedSubject!.teacher,
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
            DropdownButtonFormField<Subject>(
              value: selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Select Subject*',
                border: OutlineInputBorder(),
              ),
              items: widget.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (Subject? value) {
                setState(() {
                  selectedSubject = value;
                });
              },
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
            if (selectedSubject != null && selectedSubject!.name.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (selectedSubject!.code.isNotEmpty)
                      Text('Code: ${selectedSubject!.code}'),
                    if (selectedSubject!.teacher.isNotEmpty)
                      Text('Teacher: ${selectedSubject!.teacher}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}