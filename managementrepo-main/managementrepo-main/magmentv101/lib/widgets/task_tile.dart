import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magmentv101/services/firebase_service.dart';

class TaskTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final bool isReadOnly;
  final VoidCallback? onMoveNext;
  final bool isReworkCategory;

  const TaskTile({
    super.key,
    required this.isReadOnly,
    this.isReworkCategory = false,
    required this.task,
    this.onMoveNext,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  String projectName = "Loading...";
  String teamLeadName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (widget.task['projectId'] != null) {
      String name = await FirebaseService().fetchProjectName(
        widget.task['projectId'],
      );
      setState(() {
        projectName = name;
      });
    }

    if (widget.task['teamLeadId'] != null) {
      String name = await FirebaseService().fetchTeamLeadName(
        widget.task['teamLeadId'],
      );
      setState(() {
        teamLeadName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue =
        widget.task['dueDate'] != null &&
        (widget.task['dueDate'] as Timestamp).toDate().isBefore(
          DateTime.now(),
        ) &&
        widget.task['status'] != 'Done';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // Add task detail view navigation if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.task['taskTitle'].toUpperCase() ?? "Untitled Task",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        _getLatestWorkflowStep(widget.task['workflow']),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.isReworkCategory
                          ? 'Rework'
                          : _getLatestWorkflowStep(widget.task['workflow']) ??
                              "No Status",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Project and Team Lead info
              if (widget.task['projectId'] != null ||
                  widget.task['teamLeadId'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.task['projectId'] != null)
                      _buildInfoRow(Icons.work_outline, projectName),
                    if (widget.task['teamLeadId'] != null)
                      _buildInfoRow(
                        Icons.person_outline,
                        "Lead: $teamLeadName",
                      ),
                    const SizedBox(height: 6),
                  ],
                ),

              // Description
              if (widget.task['taskDescription'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    widget.task['taskDescription'] ?? "No Description",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

              // Due date with overdue indicator
              _buildInfoRow(
                Icons.calendar_today,
                "Due: ${widget.task['dueDate'] != null ? formatTimestamp(widget.task['dueDate']) : 'No Due Date'}",
                textStyle: theme.textTheme.bodySmall?.copyWith(
                  color: isOverdue ? Colors.red : null,
                  fontWeight: isOverdue ? FontWeight.bold : null,
                ),
                iconColor: isOverdue ? Colors.red : null,
              ),
              widget.isReworkCategory
                  ? Text(
                    "Reason: ${widget.task['reworkReason']}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                  : const SizedBox.shrink(),

              // Tags
              if (widget.task['tags'] != null &&
                  (widget.task['tags'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        (widget.task['tags'] as List)
                            .map<Widget>(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall,
                                ),
                                backgroundColor: theme.colorScheme.secondary
                                    .withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 0,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                  ),
                ),

              // Move to next button
              if (widget.onMoveNext != null &&
                  widget.task['status'] != 'Done' &&
                  !widget.isReworkCategory &&
                  widget.isReadOnly == false)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: widget.onMoveNext,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 0),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _getNextActionText(widget.task['status']),
                        style: theme.textTheme.labelMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.isReworkCategory && widget.isReadOnly == false)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: widget.onMoveNext,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 0),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Submit Rework",
                        style: theme.textTheme.labelMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getLatestWorkflowStep(List<dynamic> workflow) {
    if (workflow.isEmpty) return 'No Status';

    workflow.sort((a, b) {
      DateTime dateA = (a['updatedAt'] as Timestamp).toDate();
      DateTime dateB = (b['updatedAt'] as Timestamp).toDate();
      return dateB.compareTo(dateA); // Sort in descending order (latest first)
    });

    return workflow.first['step']; // Fetch the latest step
  }

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    Color? iconColor,
    TextStyle? textStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style:
                  textStyle ?? TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return "Tomorrow";
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'todo':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getNextActionText(String? status) {
    switch (status?.toLowerCase()) {
      case 'to do':
        return 'Start Task';
      case 'in progress':
        return 'Mark as Done';
      default:
        return 'Move Next';
    }
  }
}
