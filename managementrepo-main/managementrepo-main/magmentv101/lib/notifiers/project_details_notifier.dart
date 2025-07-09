import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magmentv101/services/firebase_service.dart';

class ProjectDetailsNotifier extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> teamLeads = [];

  ProjectDetailsNotifier() {
    fetchTeamLeads();
  }

  void fetchTasks(String projectId) async {
    isLoading = true;
    notifyListeners();

    final snapshot =
        await _firestore
            .collection('Projects')
            .doc(projectId)
            .collection('abstractTasks')
            .get();

    tasks = snapshot.docs.map((doc) => doc.data()).toList();
    isLoading = false;
    notifyListeners();
  }

  void fetchTeamLeads() async {
    try {
      teamLeads = await FirebaseService.getTeamLeads();
      notifyListeners();
    } catch (e) {
      print("Error fetching team leads: $e");
    }
  }

  void addTask({
    required String name,
    required String description,
    required String teamLeadId,
    required String departmentId,
    required DateTime dueDate,
    required String projectId,
  }) async {
    print("Adding Task - Team Lead: $teamLeadId, Department: $departmentId");

    final taskRef =
        _firestore
            .collection('Projects')
            .doc(projectId)
            .collection('abstractTasks')
            .doc(); // Generates a new document ID

    final taskId = taskRef.id; // Store the generated task ID

    final task = {
      'task_id': taskId, // Store task ID in Firestore
      'name': name,
      'description': description,
      'managerId': 'WqMPmohpEhUvNWemvWkNnoWY4rD2',
      'assignedToTeamLeadId': teamLeadId,
      'createdAt': FieldValue.serverTimestamp(),
      'dueDate': dueDate,
      'status': 'Assigned',
      'progress': 0,
      'departmentId': departmentId,
      'projectId': projectId,
    };

    await taskRef.set(task); // Save task with the generated task ID

    fetchTasks(projectId);
    notifyListeners(); // Refresh the task list
  }
}
