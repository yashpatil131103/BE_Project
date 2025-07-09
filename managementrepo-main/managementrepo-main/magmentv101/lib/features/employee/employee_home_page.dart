import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/features/auth/login_page.dart';
import 'package:magmentv101/features/auth/model/user_model.dart';
import 'package:magmentv101/features/common/fourthpage.dart';
import 'package:magmentv101/features/common/secondpage.dart';
import 'package:magmentv101/features/employee/project_tasks_page.dart';
import 'package:magmentv101/widgets/mydrawer.dart';
import 'package:magmentv101/notifiers/employee_notifier.dart';
import 'package:magmentv101/notifiers/teamLead_notifier.dart';
import 'package:magmentv101/services/firebase_service.dart';
import 'package:magmentv101/widgets/completion_status_bar.dart';
import 'package:magmentv101/widgets/expandable_desc.dart';

class EmpHomePage extends StatefulWidget {
  const EmpHomePage({Key? key}) : super(key: key);

  @override
  _EmpHomePageState createState() => _EmpHomePageState();
}

class _EmpHomePageState extends State<EmpHomePage> {
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    // Fetch assigned projects after the first frame

    fetchUserNameAsync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeNotifier>(
        context,
        listen: false,
      ).fetchAssignedProjects();
      Provider.of<TeamleadNotifier>(context, listen: false).fetchTasks();
    });
  }

  void fetchUserNameAsync() async {
    userName = await FirebaseService.fetchUserName();

    setState(() {});
  }

  TabBarView changethetabpage(
    EmployeeNotifier projectNotifier,
    List<Map<String, dynamic>> assignedProjects,
    bool isLoading,
  ) {
    return TabBarView(
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : assignedProjects.isEmpty
            ? const Center(child: Text("No projects assigned."))
            : RefreshIndicator(
              onRefresh: () async {
                await projectNotifier.fetchAssignedProjects();
              },
              child: ListView.builder(
                itemCount: assignedProjects.length,
                itemBuilder: (context, index) {
                  final project = assignedProjects[index];
                  return GestureDetector(
                    onTap: () {
                      Provider.of<EmployeeNotifier>(
                        context,
                        listen: false,
                      ).fetchProjectTasks(project['projectId']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EmployeeHomePage(
                                projectId: project['projectId'],
                              ),
                        ),
                      );
                    },
                    child: ProjectCard(project: project),
                  );
                },
              ),
            ),
        SecondPage(),
        FourthPage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectNotifier = Provider.of<EmployeeNotifier>(context);
    final assignedProjects = projectNotifier.assignedProjects;
    final isLoading = projectNotifier.isLoading;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                'Welcome ${userName.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Employee',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                Provider.of<TeamleadNotifier>(
                  context,
                  listen: false,
                ).fetchTasks();
                await projectNotifier.fetchAssignedProjects();

                setState(() {}); // Refresh the UI after fetching
              },
            ),
          ],
          bottom: TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.business)),
              Tab(icon: Icon(Icons.person)),
            ],
          ),
        ),

        drawer: MyDrawer(widget: EmpHomePage()),
        body: changethetabpage(projectNotifier, assignedProjects, isLoading),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectCard({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String projectName = project['name'] ?? "Unnamed Project";
    String description = project['description'] ?? "No description available.";
    String department = project['departmentId'] ?? "Unknown Department";
    String status = project['progress'] == 100 ? "Completed" : "Active";
    int progress = project['progress'] ?? 0;
    String teamLead = project['teamLeadId'] ?? "Not Assigned";

    // Formatting due date
    String dueDate = "No Due Date";
    if (project['dueDate'] != null) {
      DateTime parsedDate = DateTime.parse(project['dueDate']);
      dueDate = DateFormat('dd MMM yyyy').format(parsedDate);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name
            Text(
              projectName.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Description
            ExpandableDescription(description: description),

            const SizedBox(height: 10),

            // Department & Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(Icons.business, department),
                _statusChip(status),
              ],
            ),
            const SizedBox(height: 8),

            // Due Date & Progress Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(Icons.calendar_today, "Due: $dueDate"),
                // _infoChip(Icons.bar_chart, "Progress: $progress"),
              ],
            ),
            const SizedBox(height: 8),

            // Team Lead Info
            Row(
              children: [
                const Icon(
                  Icons.supervisor_account,
                  size: 18,
                  color: Colors.blue,
                ),
                const SizedBox(width: 5),
                Text(
                  "Team Lead: ${teamLead.split('_')[0].toUpperCase()}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 10),
            CompletionStatusBar(progress: progress),
          ],
        ),
      ),
    );
  }

  // Helper method for information chips
  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // Helper method for status chip
  Widget _statusChip(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      case 'on hold':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
