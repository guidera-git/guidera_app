import 'package:flutter/material.dart';
import '../models/models.dart';

/// Detail page for a specific test.
class TestDetailPage extends StatelessWidget {
  final TestItem testItem;

  TestDetailPage({required this.testItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${testItem.name} Preparation'),
        backgroundColor: testItem.color,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Section.
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/${testItem.name.toLowerCase()}_banner.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${testItem.name} Preparation',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 2))],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Description Section.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Access comprehensive resources for ${testItem.name} including full-length mock tests, past papers, performance analytics, and personalized study plans.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            // Upcoming Mock Tests Section.
            SectionHeader(title: 'Upcoming Mock Tests'),
            MockTestCard(testTitle: '${testItem.name} Full-Length Mock Test', date: 'June 15, 2025'),
            MockTestCard(testTitle: '${testItem.name} Past Paper Simulation', date: 'May 30, 2025'),
            SizedBox(height: 20),
            // Study Resources Section.
            SectionHeader(title: 'Study Resources'),
            ResourceCard(title: 'Syllabus & Exam Pattern', icon: Icons.book, onTap: () {}),
            ResourceCard(title: 'Preparation Tips & Strategies', icon: Icons.lightbulb, onTap: () {}),
            ResourceCard(title: 'Past Papers Archive', icon: Icons.history, onTap: () {}),
            SizedBox(height: 20),
            // Performance Analytics Section.
            SectionHeader(title: 'Performance Analytics'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Visualize your progress through detailed analytics and charts to identify strengths and areas for improvement.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail page for a specific subject.
class SubjectDetailPage extends StatelessWidget {
  final SubjectItem subjectItem;

  SubjectDetailPage({required this.subjectItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${subjectItem.name} Preparation'),
        backgroundColor: subjectItem.color,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Section.
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/${subjectItem.name.toLowerCase()}_banner.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${subjectItem.name} Mastery',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(2, 2))],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Description Section.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Enhance your skills in ${subjectItem.name} with targeted practice tests, quizzes, and interactive study materials designed to strengthen your foundation.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            SectionHeader(title: 'Targeted Practice Tests'),
            MockTestCard(testTitle: '${subjectItem.name} Quiz - Basics', date: 'Available Now'),
            MockTestCard(testTitle: '${subjectItem.name} Quiz - Advanced', date: 'Available Now'),
            SizedBox(height: 20),
            SectionHeader(title: 'Learning Resources'),
            ResourceCard(title: 'Conceptual Notes', icon: Icons.note, onTap: () {}),
            ResourceCard(title: 'Video Tutorials', icon: Icons.video_library, onTap: () {}),
            ResourceCard(title: 'Practice Problems', icon: Icons.quiz, onTap: () {}),
            SizedBox(height: 20),
            SectionHeader(title: 'Your Performance'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Review detailed analytics to track your progress over time and identify areas for improvement in ${subjectItem.name}.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom widget for section headers.
class SectionHeader extends StatelessWidget {
  final String title;
  SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// A custom widget for displaying mock test information.
class MockTestCard extends StatelessWidget {
  final String testTitle;
  final String date;
  MockTestCard({required this.testTitle, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.event, color: Colors.blueAccent),
        title: Text(testTitle, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Scheduled: $date'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to detailed mock test page (to be implemented).
        },
      ),
    );
  }
}

/// A custom widget for resource cards.
class ResourceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  ResourceCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
