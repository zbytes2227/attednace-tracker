import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_app_screen.dart'; // ✅ Your real home screen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;

  final List<_OnboardPageData> pages = [
    _OnboardPageData(
      icon: Icons.school,
      title: 'Welcome',
      description:
          'Manage your attendance easily with a clean and smart system.',
    ),
    _OnboardPageData(
      icon: Icons.swipe,
      title: 'Swipe to Mark',
      description:
          'Swipe right for Present and left for Absent in one move.',
      isSwipeDemo: true,
    ),
    _OnboardPageData(
      icon: Icons.analytics,
      title: 'Track Progress',
      description:
          'View weekly and monthly progress with beautiful stats.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _swipeAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0),
      end: const Offset(1.2, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_onboarded', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentPage + 1) / pages.length;

    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ✅ Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (page.isSwipeDemo) ...[
                          // ✅ Animated Swipe Tutorial
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Maths Class 09:00 - 10:00',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SlideTransition(
                                  position: _swipeAnimation,
                                  child: const Icon(
                                    Icons.pan_tool_alt,
                                    size: 40,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ] else ...[
                          AnimatedScale(
                            scale: _currentPage == index ? 1 : 0.9,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              page.icon,
                              size: 120,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],

                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24),
  child: Row(
    children: [
      if (_currentPage != pages.length - 1)
        TextButton(
          onPressed: _completeOnboarding,
          child: const Text(
            'SKIP',
            style: TextStyle(color: Colors.white70),
          ),
        ),

      Expanded(
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              if (_currentPage == pages.length - 1) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(
              _currentPage == pages.length - 1
                  ? 'Get Started'
                  : 'Next',
            ),
          ),
        ),
      ),
    ],
  ),
),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ✅ Slide data model
class _OnboardPageData {
  final IconData icon;
  final String title;
  final String description;
  final bool isSwipeDemo;

  _OnboardPageData({
    required this.icon,
    required this.title,
    required this.description,
    this.isSwipeDemo = false,
  });
}