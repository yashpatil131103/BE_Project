import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magmentv101/constants/app_theme.dart';
import 'package:magmentv101/constants/constants.dart';
import 'package:magmentv101/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/models/project_model.dart';
import 'package:magmentv101/notifiers/manager_notifier.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedDomain;
  String? _selectedTeamLead;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    final managerNotifier = Provider.of<ManagerNotifier>(
      context,
      listen: false,
    );
    managerNotifier.fetchTeamLeads();
  }

  Future<void> _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerNotifier>(
      builder: (context, managerNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Add Project",
              style: AppTheme.headlineTextStyle.copyWith(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    validator: (value) {},
                    controller: _titleController,
                    hintText: "Project Title",
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDueDate,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        validator: (value) {},
                        controller: _dueDateController,
                        hintText: "Select Due Date",
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Department>(
                    value:
                        _selectedDomain != null
                            ? Department.values.firstWhere(
                              (e) => e.name == _selectedDomain,
                              orElse: () => Department.IT,
                            )
                            : null,
                    decoration: AppTheme.inputDecoration.copyWith(
                      hintText: "Select Project Domain",
                    ),
                    items:
                        Department.values.map((dept) {
                          return DropdownMenuItem<Department>(
                            value: dept,
                            child: Text(
                              dept.name,
                              style: AppTheme.bodyTextStyle,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDomain = value?.name;
                      });
                    },
                    validator:
                        (value) => value == null ? 'Select a department' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTeamLead,
                    decoration: AppTheme.inputDecoration.copyWith(
                      hintText: "Select Team Lead",
                    ),
                    items:
                        managerNotifier.teamLeads.map((lead) {
                          String displayValue = "${lead['name']}_${lead['id']}";
                          return DropdownMenuItem<String>(
                            value: displayValue,
                            child: Text(
                              lead['name'] ?? '',
                              style: AppTheme.bodyTextStyle,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTeamLead = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    validator: (value) {},
                    controller: _descriptionController,
                    hintText: "Project Description (Max 5 lines)",
                    icon: Icons.description,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: AppTheme.elevatedButtonStyle,
                    onPressed: () async {
                      final project = ProjectModel(
                        projectId: '',
                        managerId: 'WqMPmohpEhUvNWemvWkNnoWY4rD2',
                        teamLeadId: _selectedTeamLead ?? '',
                        name: _titleController.text,
                        dueDate: _dueDateController.text,
                        description: _descriptionController.text,
                        createdAt: Timestamp.now(),
                        progress: 0,
                        status: 'Active',
                        departmentId: _selectedDomain ?? '',
                      );

                      try {
                        await managerNotifier.addProject(project);
                        managerNotifier.fetchProjects(
                          'WqMPmohpEhUvNWemvWkNnoWY4rD2',
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        print("❌ Failed to add project: $e");
                      }
                    },
                    child: Text("Add Project", style: AppTheme.buttonTextStyle),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
