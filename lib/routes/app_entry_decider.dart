import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/onboarding_screen.dart';
import '../screens/attendance_app_screen.dart'; // ✅ Correct screen

class AppEntryDecider extends StatefulWidget {
  const AppEntryDecider({Key? key}) : super(key: key);

  @override
  State<AppEntryDecider> createState() => _AppEntryDeciderState();
}

class _AppEntryDeciderState extends State<AppEntryDecider> {
  bool _loading = true;
  bool _hasOnboarded = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool('has_onboarded') ?? false;

    if (mounted) {
      setState(() {
        _hasOnboarded = value;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ Onboarding shown ONLY first time
    return _hasOnboarded
        ? const AttendanceHomePage()
        : const OnboardingScreen();
  }
}
