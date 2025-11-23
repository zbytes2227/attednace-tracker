import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoPage extends StatelessWidget {
  const DeveloperInfoPage({Key? key}) : super(key: key);

  Future<void> _openLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _developerCard({
    required String name,
    required String role,
    required String imageUrl,
    required String github,
    required String linkedin,
  }) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              role,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (github.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openLink(github),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.code),
                    label: const Text('GitHub'),
                  ),
                if (github.isNotEmpty && linkedin.isNotEmpty)
                  const SizedBox(width: 12),
                if (linkedin.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openLink(linkedin),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.business_center),
                    label: const Text('LinkedIn'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Developer info'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ✅ Developer 
            _developerCard(
              name: 'Ujjwal Kushwaha',
              role: 'Co-Creator',
              imageUrl:
                  'https://avatars.githubusercontent.com/u/111581344?v=4',
              github: 'https://github.com/zbytes2227',
              linkedin:
                  'https://www.linkedin.com/in/ujjwal-kushwaha-zbyte/',
            ),
            _developerCard(
              name: 'Tanay Anand Mishra',
              role: 'Flutter Developer & Creator',
              imageUrl:
                  'https://avatars.githubusercontent.com/u/127974995?v=4',
              github: 'https://github.com/Tanay2920003',
              linkedin:
                  'https://www.linkedin.com/in/tanayanandmishra',
            ),

            const SizedBox(height: 20),

            // ✅ Developer 2
            

            const SizedBox(height: 30),

            const Text(
              'Attendance & Timetable ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
