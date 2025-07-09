import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/notifiers/employee_notifier.dart';
import 'package:magmentv101/widgets/task_tile.dart';

class EmployeeHomePage extends StatefulWidget {
  final String projectId;
  const EmployeeHomePage({super.key, required this.projectId});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  bool showTasks = true;

  @override
  Widget build(BuildContext context) {
    final employeeNotifier = Provider.of<EmployeeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await employeeNotifier.fetchProjectTasks(widget.projectId);
            },
            tooltip: 'Refresh tasks',
          ),
        ],
      ),
      body:
          employeeNotifier.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Toggle Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade300,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showTasks = true;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(12),
                                  ),
                                  color:
                                      showTasks
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Tasks',
                                  style: TextStyle(
                                    color:
                                        showTasks
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showTasks = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                  color:
                                      !showTasks
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Tickets',
                                  style: TextStyle(
                                    color:
                                        !showTasks
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await employeeNotifier.fetchProjectTasks(
                          widget.projectId,
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children:
                              showTasks
                                  ? [
                                    TaskCategoryTile(
                                      isReadOnly: false,
                                      title: "To Do",
                                      taskList: employeeNotifier.todoTasks,
                                      onMoveNext: (task) async {
                                        employeeNotifier.updateTaskStatus(
                                          task['detailedTaskId'],
                                          'IN PROGRESS',
                                          projectId: widget.projectId,
                                        );
                                        employeeNotifier
                                            .updateDetailedTaskStatus(
                                              task['detailedTaskId'],
                                              "IN PROGRESS",
                                            );
                                      },
                                    ),
                                    TaskCategoryTile(
                                      isReadOnly: false,
                                      title: "In Progress",
                                      taskList:
                                          employeeNotifier.inProgressTasks,
                                      onMoveNext: (task) async {
                                        final githubUrl =
                                            await _askForGithubUrl(context);
                                        if (githubUrl != null) {
                                          employeeNotifier.updateTaskStatus(
                                            task['detailedTaskId'],
                                            'DONE',
                                            githubUrl: githubUrl,
                                            projectId: widget.projectId,
                                          );
                                        }

                                        employeeNotifier
                                            .updateDetailedTaskStatus(
                                              task['detailedTaskId'],
                                              "DONE",
                                            );
                                      },
                                    ),
                                    // TaskCategoryTile(
                                    //   title: "REWORK",
                                    //   taskList: employeeNotifier.reworkTasks,
                                    //   onMoveNext: (task) async {
                                    //     final githubUrl =
                                    //         await _askForGithubUrl(context);
                                    //     if (githubUrl != null) {
                                    //       employeeNotifier.updateTaskStatus(
                                    //         task['detailedTaskId'],
                                    //         'DONE',
                                    //         githubUrl: githubUrl,
                                    //         projectId: widget.projectId,
                                    //       );
                                    //     }
                                    //   },
                                    // ),
                                    TaskCategoryTile(
                                      isReadOnly: false,
                                      title: "Done",
                                      taskList: employeeNotifier.doneTasks,
                                    ),
                                    TaskCategoryTile(
                                      isReadOnly: false,
                                      title: "Rework Tickets",
                                      taskList: employeeNotifier.reworkTasks,
                                      onMoveNext: (task) async {
                                        final githubUrl =
                                            await _askForGithubUrl(context);
                                        if (githubUrl != null) {
                                          QuerySnapshot snapshot =
                                              await FirebaseFirestore.instance
                                                  .collectionGroup(
                                                    'detailed_tasks',
                                                  )
                                                  .where(
                                                    'detailedTaskId',
                                                    isEqualTo:
                                                        task['detailedTaskId'],
                                                  )
                                                  .get();

                                          if (snapshot.docs.isNotEmpty) {
                                            DocumentReference taskRef =
                                                snapshot.docs.first.reference;

                                            await taskRef.update({
                                              'rework': false,
                                            });
                                          }

                                          employeeNotifier.updateTaskStatus(
                                            task['detailedTaskId'],
                                            'DONE',
                                            githubUrl: githubUrl,
                                            projectId: widget.projectId,
                                          );
                                        }
                                      },
                                    ),
                                  ]
                                  : [
                                    TaskCategoryTile(
                                      isReadOnly: true,
                                      title: "Rework Tickets",
                                      taskList: employeeNotifier.reworkTasks,
                                      onMoveNext: (task) async {},
                                    ),
                                  ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

Future<String?> _askForGithubUrl(BuildContext context) async {
  TextEditingController urlController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Enter GitHub Link"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: "Paste your GitHub link here...",
            ),
            validator: (value) {
              final pattern =
                  r'^(https?:\/\/)?(www\.)?github\.com\/[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$';
              final regExp = RegExp(pattern);

              if (value == null || value.trim().isEmpty) {
                return 'Link cannot be empty';
              } else if (!regExp.hasMatch(value.trim())) {
                return 'Please enter a valid GitHub repository URL';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, urlController.text.trim());
              }
            },
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );
}

class TaskCategoryTile extends StatelessWidget {
  final bool isReadOnly;
  final String title;
  final List<Map<String, dynamic>> taskList;
  final Function(Map<String, dynamic>)? onMoveNext;

  const TaskCategoryTile({
    Key? key,
    required this.title,
    required this.isReadOnly,
    required this.taskList,
    this.onMoveNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDoneCategory = title.toLowerCase() == 'done';
    final isReworkCategory = title.toLowerCase() == 'rework tickets';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          "$title (${taskList.length})",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        initiallyExpanded: false,
        collapsedBackgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
          0.3,
        ),
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          if (taskList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No tasks available",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            )
          else
            ...taskList.map(
              (task) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TaskTile(
                  isReworkCategory: isReworkCategory,
                  isReadOnly: isReadOnly,
                  task: task,
                  onMoveNext:
                      isDoneCategory ? null : () => onMoveNext?.call(task),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
