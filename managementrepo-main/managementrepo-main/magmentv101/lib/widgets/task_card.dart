import 'package:flutter/material.dart';
import 'package:magmentv101/constants/app_theme.dart';

class TaskCard extends StatelessWidget {
  final String name;
  final String description;
  final double progress;
  final String teamLead;
  final String dueDate;

  const TaskCard({
    required this.name,
    required this.description,
    required this.progress,
    required this.teamLead,
    required this.dueDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name.toUpperCase(),
                  style: AppTheme.headlineTextStyle.copyWith(fontSize: 18),
                ),
                Chip(
                  avatar: const Icon(Icons.calendar_today, color: Colors.white),
                  label: Text(
                    dueDate,
                    style: AppTheme.chipTextStyle.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Team Lead: ",
                  style: AppTheme.bodyTextStyle.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  teamLead.split('_')[0],
                  style: AppTheme.bodyTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: AppTheme.bodyTextStyle.copyWith(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
