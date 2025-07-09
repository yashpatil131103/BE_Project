import 'package:flutter/material.dart';

class aboutpage extends StatelessWidget {
  const aboutpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '📌 Welcome to Mangment App!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your all-in-one solution for efficient and secure project management.\n\n'
                'Our platform is designed to streamline communication and task coordination '
                'between Managers, Team Leads, and Employees. From project creation to task submission, '
                'we make every step seamless and organized.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                '🔍 Key Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                  '• Role-Based Portals: Custom dashboards for Managers, Team Leads, and Employees.'),
              Text(
                  '• Project Lifecycle Tracking: Create, assign, monitor, and complete projects in one place.'),
              Text(
                  '• Task Management: Assign tasks with detailed descriptions and track progress.'),
              Text(
                  '• Issue Tracking: Raise and resolve project-related issues.'),
              Text('• Secure Access: Role-based login and data protection.'),
              Text('• Submission System: Submit links and tasks easily.'),
              SizedBox(height: 24),
              Text(
                '🎯 Our Mission',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'To simplify project collaboration and enhance productivity through a secure, '
                'intuitive, and structured system that supports teams at every level.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                '📞 Contact Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Have questions or suggestions?'),
              Text('Reach out to us at: yashpatil131103@gmail.com'),
            ],
          ),
        ),
      ),
    );
  }
}
