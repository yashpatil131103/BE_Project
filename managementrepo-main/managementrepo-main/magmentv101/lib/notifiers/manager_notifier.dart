import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/models/project_model.dart';
import 'package:magmentv101/services/firebase_service.dart';

import 'employee_notifier.dart';

class ManagerNotifier extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _teamLeads = [];
  List<Map<String, dynamic>> get teamLeads => _teamLeads;

  Future<void> updateProjectProgress(String projectId) async {
    try {
      // Step 1: Fetch all abstractTasks under the project
      QuerySnapshot abstractTasksSnapshot =
          await FirebaseFirestore.instance
              .collection('Projects')
              .doc(projectId)
              .collection('abstractTasks')
              .get();

      if (abstractTasksSnapshot.docs.isEmpty) {
        print("No abstract tasks found for project: $projectId");
        return;
      }

      // Step 2: Extract progress values
      List<int> progressList =
          abstractTasksSnapshot.docs
              .map(
                (doc) => (doc.data() as Map<String, dynamic>)['progress'] ?? 0,
              )
              .cast<int>()
              .toList();

      // Step 3: Calculate average
      int total = progressList.fold(0, (sum, p) => sum + p);
      int averageProgress = (total / progressList.length).round();

      // Step 4: Update project document
      await FirebaseFirestore.instance
          .collection('Projects')
          .doc(projectId)
          .update({'progress': averageProgress});

      print("Updated project $projectId progress to $averageProgress%");
    } catch (e) {
      print("Error updating project progress: $e");
    }
  }

  Future<void> fetchProjects(String managerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await FirebaseService.getProjectsByManager(managerId);
      for (var project in _projects) {
        await updateProjectProgress(project.projectId);
      }
      // Sort projects by due date
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamLeads() async {
    try {
      _teamLeads = await FirebaseService.getTeamLeads();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addProject(ProjectModel project) async {
    try {
      await FirebaseService.addProject(project);
      _projects.add(project);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
