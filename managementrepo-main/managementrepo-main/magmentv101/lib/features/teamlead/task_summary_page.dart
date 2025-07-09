import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/notifiers/teamLead_notifier.dart';
import 'package:magmentv101/widgets/completion_status_bar.dart';
import 'package:magmentv101/widgets/expandable_desc.dart';
import 'package:magmentv101/widgets/teamlead_task_summary_widget.dart';

class TaskSummaryPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskSummaryPage({Key? key, required this.task}) : super(key: key);

  @override
  _TaskSummaryPageState createState() => _TaskSummaryPageState();
}

class _TaskSummaryPageState extends State<TaskSummaryPage> {
  bool showTasks = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWorkflow();
    });
  }

  Future<void> _fetchWorkflow() async {
    final teamLeadNotifier = Provider.of<TeamleadNotifier>(
      context,
      listen: false,
    );
    await teamLeadNotifier.fetchWorkflow(widget.task);
  }

  Widget _buildEmployeeAvatar(String employee) {
    List<String> parts = employee.split('_');
    String email = parts[0];
    String name = parts.length > 1 ? parts[1] : "Unknown";
    String initials = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return Column(
      children: [
        Tooltip(
          message: "$name\n$email",
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 20,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task['taskTitle'] ?? "Task Summary"),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Task Details Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.only(
              //   bottomLeft: Radius.circular(20),
              //   bottomRight: Radius.circular(20),
              // ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task['taskTitle'].toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 12),
                ExpandableDescription(
                  description: widget.task['taskDescription'],
                ),
                SizedBox(height: 16),
                Text(
                  "Assigned Team:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        (widget.task['assignedToEmployeeIds'] as List<dynamic>)
                            .map(
                              (emp) => Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: _buildEmployeeAvatar(emp),
                              ),
                            )
                            .toList(),
                  ),
                ),
                SizedBox(height: 16),
                CompletionStatusBar(progress: widget.task['progress']),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  "Workflow Steps",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TeamLeadTaskSummaryWidget(
              taskId: widget.task['detailedTaskId'],
              progress:
                  (widget.task['progress'] is double)
                      ? (widget.task['progress'] as double).toInt()
                      : int.tryParse(widget.task['progress'].toString()) ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
