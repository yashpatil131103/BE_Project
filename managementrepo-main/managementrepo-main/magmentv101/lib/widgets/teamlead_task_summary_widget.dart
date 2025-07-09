import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/notifiers/employee_notifier.dart';
import 'package:magmentv101/notifiers/teamLead_notifier.dart';
import 'package:magmentv101/widgets/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamLeadTaskSummaryWidget extends StatefulWidget {
  final String taskId;
  final int progress;

  const TeamLeadTaskSummaryWidget({
    super.key,
    required this.taskId,
    required this.progress,
  });

  @override
  _TeamLeadTaskSummaryWidgetState createState() =>
      _TeamLeadTaskSummaryWidgetState();
}

class _TeamLeadTaskSummaryWidgetState extends State<TeamLeadTaskSummaryWidget> {
  bool isLoading = true;
  TextEditingController reworkReasonController = TextEditingController();
  Future<void> launchGitHubLink(String url) async {
    final uri = Uri.parse(url.trim());

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // <- important
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildUserAvatar(String userInfo) {
    final parts = userInfo.split('_');
    final email = parts[0];
    final name = parts.length > 1 ? parts[1] : 'Unknown';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        Text(
          "Updated By: ",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Tooltip(
          message: 'Name: $name\nEmail: $email',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 16,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(
    Map<String, dynamic> step,
    Color statusColor,
    bool isDoneCard,
    bool isSubmittedCard,
    bool isReworkCard,
  ) {
    final updatedAt =
        step['updatedAt'] is String
            ? DateTime.parse(step['updatedAt'])
            : step['updatedAt'] as DateTime;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  step['step'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    step['step'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (step['updatedBy'] != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  _buildUserAvatar(step['updatedBy']),
                ],
              ),
            SizedBox(height: 8),
            _buildDetailRow(
              Icons.access_time,
              "Updated At:",
              DateFormat('MMM dd, yyyy - hh:mm a').format(updatedAt),
            ),
            if (step['githubUrl'] != null && step['githubUrl'].isNotEmpty)
              SizedBox(height: 8),
            if (step['githubUrl'] != null && step['githubUrl'].isNotEmpty)
              _buildClickableDetailRow(
                Icons.code,
                "GitHub URL:",
                step['githubUrl'],
                onTap: () async {
                  // Handle GitHub URL tap
                  final githubUrl = step['githubUrl'];
                  if (githubUrl != null) {
                    await launchGitHubLink(githubUrl);
                  }
                },
              ),
            if (step['step'] == 'DONE' && !isDoneCard)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.check_circle, size: 18),
                    label: Text("Mark as Done"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.36,
                        60,
                      ),
                      maximumSize: Size(
                        MediaQuery.of(context).size.width * 0.36,
                        60,
                      ),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () async {
                      // final githubUrl = step['githubUrl'];
                      // if (githubUrl != null) {
                      //   await launchGitHubLink(githubUrl);
                      // }

                      final teamLeadNotifier = Provider.of<TeamleadNotifier>(
                        context,
                        listen: false,
                      );
                      final empLeadNotifier = Provider.of<EmployeeNotifier>(
                        context,
                        listen: false,
                      );

                      await teamLeadNotifier.markDetailedTaskAsDone(
                        widget.taskId,
                        {'tasksCompleted': true},
                      );

                      empLeadNotifier.updateDetailedTaskStatus(
                        widget.taskId,
                        "SUBMITTED",
                      );
                      teamLeadNotifier.fetchTasks();
                      SnackBarHelper.showSnackBar(
                        context,
                        "Task marked as done.",
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                      Navigator.pop(context);
                      await teamLeadNotifier.fetchWorkflow(
                        teamLeadNotifier.tasks.firstWhere(
                          (task) => task['detailedTaskId'] == widget.taskId,
                        ),
                      );

                      teamLeadNotifier.fetchTasks();

                      empLeadNotifier.fetchAssignedProjects();
                    },
                  ),
                  SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: Icon(
                      Icons.report_problem,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: Text(
                      "Raise a Ticket",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.36,
                        60,
                      ),
                      maximumSize: Size(
                        MediaQuery.of(context).size.width * 0.36,
                        60,
                      ),
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Raise a Ticket'),
                            content: TextField(
                              controller: reworkReasonController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Enter reason for rework...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final reason =
                                      reworkReasonController.text.trim();
                                  if (reason.isEmpty) {
                                    SnackBarHelper.showSnackBar(
                                      context,
                                      "Please enter a valid reason.",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }

                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog

                                  final teamLeadNotifier =
                                      Provider.of<TeamleadNotifier>(
                                        context,
                                        listen: false,
                                      );
                                  await teamLeadNotifier.raiseTicket(
                                    widget.taskId,
                                    {'rework': true, 'reworkReason': reason},
                                  );
                                  SnackBarHelper.showSnackBar(
                                    context,
                                    "Ticket Raised Successfully.",
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                  );
                                  Navigator.pop(context);
                                  await teamLeadNotifier.fetchWorkflow(
                                    teamLeadNotifier.tasks.firstWhere(
                                      (task) =>
                                          task['detailedTaskId'] ==
                                          widget.taskId,
                                    ),
                                  );
                                },
                                child: Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableDetailRow(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return InkWell(onTap: onTap, child: _buildDetailRow(icon, label, value));
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> steps,
    Color color,
    bool isDoneCard,
    bool isSubmittedCard,
    bool isReworkCard,
  ) {
    return steps.isEmpty
        ? SizedBox() // Hide section if there are no steps
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...steps.map(
              (step) => _buildStepCard(
                step,
                color,
                isDoneCard,
                isSubmittedCard,
                isReworkCard,
              ),
            ),
          ],
        );
  }

  @override
  Widget build(BuildContext context) {
    final teamLeadNotifier = Provider.of<TeamleadNotifier>(
      context,
      listen: true,
    ); // Listen for updates
    return teamLeadNotifier.isLoadingWorkflow
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSection(
                "IN PROGRESS",
                teamLeadNotifier.todoSteps,
                Colors.orange,
                false,
                false,
                false,
              ),
              _buildSection(
                "SUBMITTED",
                teamLeadNotifier.submittedSteps,
                Colors.blue,
                false,
                true,
                false,
              ),
              _buildSection(
                "DONE",
                teamLeadNotifier.doneSteps,
                Colors.green,
                true,
                false,
                false,
              ),
              _buildSection(
                "REWORK",
                teamLeadNotifier.reworkSteps,
                Colors.green,
                true,
                true,
                true,
              ),
              // _buildExpansionTile("IN PROGRESS", teamLeadNotifier.todoSteps,
              //     Colors.orange, false),
              // _buildExpansionTile("SUBMITTED",
              //     teamLeadNotifier.submittedSteps, Colors.blue, false),
              // _buildExpansionTile(
              //     "DONE", teamLeadNotifier.doneSteps, Colors.green, true),
            ],
          ),
        );
  }
}
