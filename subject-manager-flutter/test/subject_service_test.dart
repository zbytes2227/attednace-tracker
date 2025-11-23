import 'package:flutter_test/flutter_test.dart';
import 'package:subject_manager_flutter/src/models/subject.dart';
import 'package:subject_manager_flutter/src/services/subject_service.dart';

void main() {
  group('SubjectService', () {
    late SubjectService subjectService;

    setUp(() {
      subjectService = SubjectService();
    });

    test('should add a subject', () {
      final subject = Subject(name: 'Mathematics', code: 'MATH101', teacher: 'Dr. Smith');
      subjectService.addSubject(subject);
      expect(subjectService.getSubjects().length, 1);
      expect(subjectService.getSubjects().first.name, 'Mathematics');
    });

    test('should edit a subject', () {
      final subject = Subject(name: 'Physics', code: 'PHY101', teacher: 'Dr. Johnson');
      subjectService.addSubject(subject);
      final updatedSubject = Subject(name: 'Advanced Physics', code: 'PHY201', teacher: 'Dr. Johnson');
      subjectService.editSubject(subject.code, updatedSubject);
      expect(subjectService.getSubjects().first.name, 'Advanced Physics');
    });

    test('should delete a subject', () {
      final subject = Subject(name: 'Chemistry', code: 'CHE101', teacher: 'Dr. Brown');
      subjectService.addSubject(subject);
      subjectService.deleteSubject(subject.code);
      expect(subjectService.getSubjects().isEmpty, true);
    });

    test('should return an empty list when no subjects are added', () {
      expect(subjectService.getSubjects().isEmpty, true);
    });
  });
}