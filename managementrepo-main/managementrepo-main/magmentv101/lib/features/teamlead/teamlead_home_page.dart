import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/features/common/fourthpage.dart';
import 'package:magmentv101/features/common/secondpage.dart';
import 'package:magmentv101/widgets/mydrawer.dart';
import 'package:magmentv101/features/teamlead/task_details_page.dart';
import 'package:magmentv101/notifiers/teamLead_notifier.dart';
import 'package:magmentv101/services/firebase_service.dart';
import 'package:magmentv101/widgets/completion_status_bar.dart';

class TeamleadHomePage extends StatefulWidget {
  const TeamleadHomePage({super.key});

  @override
  State<TeamleadHomePage> createState() => _TeamleadHomePageState();
}

class _TeamleadHomePageState extends State<TeamleadHomePage> {
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserNameAsync();
  }

  void fetchUserNameAsync() async {
    final fetchedName = await FirebaseService.fetchUserName();
    setState(() {
      userName = fetchedName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ChangeNotifierProvider(
        create: (_) => TeamleadNotifier()..fetchTasks(),
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
                  'Team lead',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  final notifier = Provider.of<TeamleadNotifier>(
                    context,
                    listen: false,
                  );
                  notifier.fetchTasks();
                },
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: CircleAvatar(
              //     backgroundColor: Colors.grey[200],
              //     child: Text(
              //       userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              //       style: const TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //   ),
              // ),
            ],
            bottom: const TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.business)),
                Tab(icon: Icon(Icons.person)),
              ],
            ),
          ),

          drawer: const MyDrawer(widget: TeamleadHomePage()),
          body: TabBarView(
            children: [
              Consumer<TeamleadNotifier>(
                builder: (context, notifier, _) {
                  if (notifier.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (notifier.tasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => notifier.fetchTasks(),
                    child: ListView.builder(
                      itemCount: notifier.tasks.length,
                      itemBuilder: (context, index) {
                        final task = notifier.tasks[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailsPage(task: task),
                              ),
                            );
                          },
                          child: TaskCard(task: task),
                        );
                      },
                    ),
                  );
                },
              ),
              const SecondPage(),
              const FourthPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Format the due date
    String formattedDate = "N/A";
    if (task['dueDate'] != null && task['dueDate'] is Timestamp) {
      final DateTime dueDate = task['dueDate'].toDate();
      formattedDate = DateFormat('dd MMM yyyy').format(dueDate);
    }

    // Safely get the task name
    final String taskName =
        (task['name'] ?? 'No Title').toString().toUpperCase();

    // Handle progress: cast to double, then convert to int
    final int progress = ((task['progress'] ?? 0) as num).toInt();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: task name + due date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    taskName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar widget
            CompletionStatusBar(progress: progress),
          ],
        ),
      ),
    );
  }
}
