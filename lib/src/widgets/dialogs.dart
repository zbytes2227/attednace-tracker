import 'package:flutter/material.dart';
import '../models/models.dart';

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
