import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/constants/app_theme.dart';
import 'package:magmentv101/constants/constants.dart';
import 'package:magmentv101/notifiers/project_details_notifier.dart';
import 'package:magmentv101/widgets/task_card.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  @override
  void initState() {
    super.initState();
    final detailsNotifier = Provider.of<ProjectDetailsNotifier>(
      context,
      listen: false,
    );
    detailsNotifier.fetchTeamLeads();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              ProjectDetailsNotifier()
                ..fetchTeamLeads()
                ..fetchTasks(widget.projectId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Project Details'),

          // actions: [
          //   IconButton(
          //     onPressed: () {
          //       setState(() {});
          //     },
          //     icon: Icon(Icons.refresh),
          //   ),
          // ],
        ),
        body: Consumer<ProjectDetailsNotifier>(
          builder: (context, notifier, _) {
            if (notifier.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (notifier.tasks.isEmpty) {
              return Center(child: Text('No tasks available.'));
            }

            return RefreshIndicator(
              onRefresh: () {
                notifier.fetchTasks(widget.projectId);
                return Future.value();
              },
              child: ListView.builder(
                itemCount: notifier.tasks.length,
                itemBuilder: (context, index) {
                  final task = notifier.tasks[index];
                  final dueDate = (task['dueDate']).toDate();
                  final formattedDueDate =
                      "${dueDate.day}/${dueDate.month}/${dueDate.year}";

                  return TaskCard(
                    name: task['name'],
                    description: task['description'],
                    progress: task['progress'] / 100,
                    teamLead: task['assignedToTeamLeadId'],
                    dueDate: formattedDueDate,
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primaryColor,
          onPressed: () => _showAddTaskBottomSheet(context),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    final notifier = Provider.of<ProjectDetailsNotifier>(
      context,
      listen: false,
    );
    final _formKey = GlobalKey<FormState>();
    String? name, description, teamLeadId, department;
    DateTime? dueDate;
    final TextEditingController dueDateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Add Task", style: AppTheme.headlineTextStyle),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: AppTheme.inputDecoration.copyWith(
                      labelText: 'Name',
                    ),
                    onSaved: (value) => name = value,
                    validator:
                        (value) => value!.isEmpty ? 'Enter a name' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: AppTheme.inputDecoration.copyWith(
                      labelText: 'Description',
                    ),
                    onSaved: (value) => description = value,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter a description' : null,
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: AppTheme.inputDecoration.copyWith(
                      labelText: 'Team Lead',
                    ),
                    value: teamLeadId,
                    items:
                        notifier.teamLeads.map((lead) {
                          final leadId = "${lead['name']}_${lead['id']}";
                          return DropdownMenuItem<String>(
                            value: leadId,
                            child: Expanded(
                              child: Text(
                                "${lead["id"]}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      teamLeadId = value;
                    },
                    validator:
                        (value) => value == null ? 'Select a team lead' : null,
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<Department>(
                    decoration: AppTheme.inputDecoration.copyWith(
                      labelText: 'Department',
                    ),
                    value:
                        department != null
                            ? Department.values.firstWhere(
                              (e) => e.name == department,
                              orElse: () => Department.HR,
                            )
                            : null,
                    items:
                        Department.values.map((dept) {
                          return DropdownMenuItem<Department>(
                            value: dept,
                            child: Text(dept.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      department = value?.name;
                    },
                    validator:
                        (value) => value == null ? 'Select a department' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: dueDateController,
                    decoration: AppTheme.inputDecoration.copyWith(
                      labelText: 'Due Date',
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        dueDate = pickedDate;
                        dueDateController.text =
                            "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}";
                      }
                    },
                    validator:
                        (value) => dueDate == null ? 'Select a due date' : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: AppTheme.elevatedButtonStyle,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        notifier.addTask(
                          name: name!,
                          description: description!,
                          teamLeadId: teamLeadId!,
                          departmentId: department!,
                          dueDate: dueDate!,
                          projectId: widget.projectId,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Add Task", style: AppTheme.buttonTextStyle),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
