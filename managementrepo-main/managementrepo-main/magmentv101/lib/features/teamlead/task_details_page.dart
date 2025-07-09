import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/features/teamlead/task_summary_page.dart';
import 'package:magmentv101/notifiers/teamLead_notifier.dart';
import 'package:intl/intl.dart';
import 'package:magmentv101/widgets/completion_status_bar.dart';
import 'package:magmentv101/widgets/date_picker_widget.dart';
import 'package:magmentv101/widgets/expandable_desc.dart';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _progress = 0;
  String _status = "TODO";
  List<String> selectedEmployees = [];
  List<String> tags = [];
  bool isExpanded = false;
  bool _isTaskSelected = true;
  final TextEditingController _dueDateController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    Provider.of<TeamleadNotifier>(context, listen: false).fetchEmployess();
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat.yMMMd().format(timestamp.toDate());
  }

  void addTag() {
    if (_tagsController.text.isNotEmpty) {
      setState(() {
        tags.add(_tagsController.text.trim());
        _tagsController.clear();
      });
    }
  }

  Future<void> saveTaskDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final taskData = {
        "abstractTaskId": widget.task['task_id'],
        "projectId": widget.task['projectId'] ?? "",
        "taskTitle": _titleController.text,
        "taskDescription": _descriptionController.text,
        "teamLeadId": user.email,
        "updatedAt": FieldValue.serverTimestamp(),
        "tags": tags,
        "dueDate": _selectedDueDate,
        "taskCompleted": false,
        "status": _status,
        "progress": _progress,
        "rework": false,
        "workflow": FieldValue.arrayUnion([
          {"step": _status, "updatedAt": Timestamp.now()},
        ]),
        "assignedToEmployeeIds": selectedEmployees,
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Always create new task (no editing existing ones)
      final docRef = await FirebaseFirestore.instance
          .collection('Projects')
          .doc(widget.task['projectId'])
          .collection('abstractTasks')
          .doc(widget.task['task_id'])
          .collection('detailed_tasks')
          .add(taskData);

      // Store the detailed task ID in the document
      await docRef.update({'detailedTaskId': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Task created successfully!"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
      setState(() {
        tags.clear();
        selectedEmployees.clear();
        _status = "TODO";
        _progress = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating task: $e"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTaskDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Consumer<TeamleadNotifier>(
              builder: (context, notifier, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Create New Task",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: "Task Title",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Tags",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children:
                                    tags
                                        .map(
                                          (tag) => Chip(
                                            label: Text(tag),
                                            backgroundColor: Colors.blue[100],
                                            deleteIcon: const Icon(
                                              Icons.close,
                                              size: 16,
                                            ),
                                            onDeleted: () {
                                              setState(() {
                                                tags.remove(tag);
                                              });
                                            },
                                          ),
                                        )
                                        .toList(),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagsController,
                                    decoration: InputDecoration(
                                      labelText: "Add tag",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                  ),
                                  onPressed: addTag,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _status,
                              items:
                                  ["TODO", "IN PROGRESS", "DONE", "REWORK"]
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _status = value;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Due Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            DatePickerField(
                              controller: _dueDateController,
                              initialDate: _selectedDueDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedDueDate = date;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Assign To",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              items:
                                  notifier.employees.map((employee) {
                                    String newValue =
                                        "${employee['id']}_${employee['name']}";
                                    return DropdownMenuItem<String>(
                                      value: newValue,
                                      child: Text(employee['name']),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null &&
                                    !selectedEmployees.contains(value)) {
                                  setState(() {
                                    selectedEmployees.add(value);
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            if (selectedEmployees.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    selectedEmployees.map((empId) {
                                      final employee = notifier.employees
                                          .firstWhere(
                                            (emp) => emp['id'] == empId,
                                            orElse: () => {'name': 'Unknown'},
                                          );
                                      return Chip(
                                        label: Text(employee['name']),
                                        backgroundColor: Colors.green[100],
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            selectedEmployees.remove(empId);
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: saveTaskDetails,
                        child: const Text(
                          "Create Task",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamleadNotifier()..fetchEmployess(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Task Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: _showTaskDetailsSheet,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.task['name'].toUpperCase() ??
                                'No Title'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 12,
                        //     vertical: 6,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: _getStatusColor(
                        //         widget.task['status']), // Static status
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: Text(
                        //     widget.task['status'] ?? "TODO",
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontWeight: FontWeight.bold,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Due: ${formatTimestamp(widget.task['dueDate'])}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ExpandableDescription(
                      description: widget.task['description'],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Task/Ticket Toggle
              Container(
                decoration: BoxDecoration(
                  // color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isTaskSelected = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    _isTaskSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Task",
                                  style: TextStyle(
                                    color:
                                        _isTaskSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isTaskSelected = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    !_isTaskSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Ticket",
                                  style: TextStyle(
                                    color:
                                        !_isTaskSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_isTaskSelected) ...[
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Projects')
                                .doc(widget.task['projectId'])
                                .collection('abstractTasks')
                                .doc(widget.task['task_id'])
                                .collection('detailed_tasks')
                                .where('rework', isEqualTo: false)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No detailed tasks available."),
                            );
                          }

                          final detailedTasks = snapshot.data!.docs;

                          // Convert and sort based on status priority
                          final taskList =
                              detailedTasks
                                  .map(
                                    (doc) => doc.data() as Map<String, dynamic>,
                                  )
                                  .toList();

                          const statusOrder = {
                            "TODO": 0,
                            "IN PROGRESS": 1,
                            "DONE": 2,
                          };
                          taskList.sort((a, b) {
                            final aStatus =
                                a['status']?.toString().toUpperCase() ?? '';
                            final bStatus =
                                b['status']?.toString().toUpperCase() ?? '';
                            return (statusOrder[aStatus] ?? 3).compareTo(
                              statusOrder[bStatus] ?? 3,
                            );
                          });

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: taskList.length,
                            itemBuilder: (context, index) {
                              final task = taskList[index];
                              final employees =
                                  task['assignedToEmployeeIds'] ?? [];
                              final tags = task['tags'] ?? [];
                              // final isSubmitted =
                              //     task['taskCompleted'] ?? false;
                              // final isRework = task['rework'] ?? false;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                TaskSummaryPage(task: task),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and Status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                task['taskTitle']
                                                        ?.toUpperCase() ??
                                                    "Untitled Task",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                  (task['taskCompleted'] ==
                                                              false &&
                                                          task['status'] ==
                                                              "DONE")
                                                      ? "SUBMITTED"
                                                      : task['status'],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                (task['taskCompleted'] ==
                                                            false &&
                                                        task['status'] ==
                                                            "DONE")
                                                    ? "SUBMITTED"
                                                    : (task['status'] ??
                                                        "TODO"),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8),

                                        ExpandableDescription(
                                          description:
                                              task['taskDescription'] ??
                                              "No description",
                                        ),

                                        SizedBox(height: 12),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Due: ${task['dueDate'] != null ? formatTimestamp(task['dueDate']) : 'No Due Date'}",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 12),

                                        if (tags.isNotEmpty)
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children:
                                                tags
                                                    .map<Widget>(
                                                      (tag) => Chip(
                                                        label: Text(tag),
                                                        labelStyle: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                        backgroundColor:
                                                            Colors.blue[50],
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                      ),
                                                    )
                                                    .toList(),
                                          ),

                                        SizedBox(height: 8),

                                        if (employees.isNotEmpty)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Assigned to:",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: employees.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    String employeeData =
                                                        employees[index];
                                                    List<String> parts =
                                                        employeeData.split('_');
                                                    String email = parts[0];
                                                    String name =
                                                        parts.length > 1
                                                            ? parts[1]
                                                            : "Unknown";
                                                    String initials =
                                                        name.isNotEmpty
                                                            ? name[0]
                                                                .toUpperCase()
                                                            : "?";

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                  name,
                                                                ),
                                                                content: Text(
                                                                  email,
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                        ),
                                                                    child:
                                                                        const Text(
                                                                          "Close",
                                                                        ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Tooltip(
                                                          message:
                                                              "$name\n$email",
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.blue,
                                                            radius: 16,
                                                            child: Text(
                                                              initials,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                        CompletionStatusBar(
                                          progress:
                                              (task['progress'] is double)
                                                  ? (task['progress'] as double)
                                                      .toInt()
                                                  : int.tryParse(
                                                        task['progress']
                                                            .toString(),
                                                      ) ??
                                                      0,
                                        ),

                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                    if (!_isTaskSelected) ...[
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Projects')
                                .doc(widget.task['projectId'])
                                .collection('abstractTasks')
                                .doc(widget.task['task_id'])
                                .collection('detailed_tasks')
                                .where('rework', isEqualTo: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No detailed tasks available."),
                            );
                          }

                          final detailedTasks = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: detailedTasks.length,
                            itemBuilder: (context, index) {
                              final task =
                                  detailedTasks[index].data()
                                      as Map<String, dynamic>;
                              final employees =
                                  task['assignedToEmployeeIds'] ?? [];
                              final tags = task['tags'] ?? [];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // Add navigation to task detail view if needed
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                TaskSummaryPage(task: task),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and Status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                task['taskTitle']
                                                        .toUpperCase() ??
                                                    "Untitled Task",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                  "REWORK",
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "REWORK",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8),

                                        ExpandableDescription(
                                          description:
                                              task['taskDescription'] ??
                                              "No description",
                                        ),

                                        SizedBox(height: 12),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Due: ${task['dueDate'] != null ? formatTimestamp(task['dueDate']) : 'No Due Date'}",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 12),

                                        // Tags (if any)
                                        if (tags.isNotEmpty)
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children:
                                                tags
                                                    .map<Widget>(
                                                      (tag) => Chip(
                                                        label: Text(tag),
                                                        labelStyle: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                        backgroundColor:
                                                            Colors.blue[50],
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                      ),
                                                    )
                                                    .toList(),
                                          ),

                                        SizedBox(height: 8),

                                        if (employees.isNotEmpty)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Assigned to:",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: employees.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    String employeeData =
                                                        employees[index];
                                                    List<String> parts =
                                                        employeeData.split('_');
                                                    String email = parts[0];
                                                    String name =
                                                        parts.length > 1
                                                            ? parts[1]
                                                            : "Unknown";
                                                    String initials =
                                                        name.isNotEmpty
                                                            ? name[0]
                                                                .toUpperCase()
                                                            : "?";

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                  name,
                                                                ),
                                                                content: Text(
                                                                  email,
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () => Navigator.pop(
                                                                          context,
                                                                        ),
                                                                    child:
                                                                        const Text(
                                                                          "Close",
                                                                        ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Tooltip(
                                                          message:
                                                              "$name\n$email",
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .blue, // Change color if needed
                                                            radius: 16,
                                                            child: Text(
                                                              initials,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 8),

                                        Text(
                                          "Rework Reason: ${task['reworkReason'] ?? 'No reason provided'}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        CompletionStatusBar(
                                          progress:
                                              (task['progress'] is double)
                                                  ? (task['progress'] as double)
                                                      .toInt()
                                                  : int.tryParse(
                                                        task['progress']
                                                            .toString(),
                                                      ) ??
                                                      0,
                                        ),

                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "TODO":
        return Colors.orange;
      case "IN PROGRESS":
        return Colors.blue;
      case "DONE":
        return Colors.green;
      case "REWORK":
        return Colors.purple;
      case "SUBMITTED":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
