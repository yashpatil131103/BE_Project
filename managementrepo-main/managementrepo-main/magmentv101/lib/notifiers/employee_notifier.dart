import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magmentv101/services/firebase_service.dart';

class EmployeeNotifier extends ChangeNotifier {
  bool isLoading = true;
  List<Map<String, dynamic>> todoTasks = [];
  List<Map<String, dynamic>> inProgressTasks = [];
  List<Map<String, dynamic>> doneTasks = [];
  List<Map<String, dynamic>> assignedProjects = [];
  List<Map<String, dynamic>> reworkTasks = [];
  EmployeeNotifier() {
    // fetchTasks();
  }

  Future<void> updateTaskStatus(
    String taskId,
    String newStatus, {
    String? githubUrl,
    bool? submitted,
    required String projectId,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('detailed_tasks')
              .where('detailedTaskId', isEqualTo: taskId)
              .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentReference taskRef = snapshot.docs.first.reference;
        DocumentSnapshot taskSnap = await taskRef.get();

        String updatedByKey =
            "${user.email}_${await FirebaseService.fetchUserName()}";

        List<dynamic> workflow = List.from(taskSnap['workflow'] ?? []);

        // Step 1: Try to find entry with this user's updatedBy
        int existingIndex = workflow.indexWhere(
          (entry) => entry['updatedBy'] == updatedByKey,
        );

        // Step 2: If not found, try to find the first entry with no updatedBy (initial TODO)
        if (existingIndex == -1) {
          existingIndex = workflow.indexWhere(
            (entry) => entry['updatedBy'] == null && entry['step'] == 'TODO',
          );
        }

        Map<String, dynamic> newEntry = {
          'step': newStatus,
          'updatedAt': Timestamp.now(),
          'updatedBy': updatedByKey,
          'submitted': submitted ?? false,
        };

        if (newStatus == 'DONE' && githubUrl != null) {
          newEntry['githubUrl'] = githubUrl;
        }

        if (existingIndex != -1) {
          // Update the existing entry (either user's or initial TODO)
          workflow[existingIndex] = newEntry;
        } else {
          // Add new entry
          workflow.add(newEntry);
        }

        await taskRef.update({'status': newStatus, 'workflow': workflow});
      }

      await fetchProjectTasks(projectId);
    } catch (e) {
      print("Error updating task status: $e");
    }
  }

  Future<void> fetchProjectTasks(String projectId) async {
    isLoading = true;
    notifyListeners();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Fetch all detailed tasks under the selected project
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('detailed_tasks')
              .where(
                'projectId',
                isEqualTo: projectId,
              ) // Fetch tasks for the selected project
              .get();

      print(snapshot);
      List<Map<String, dynamic>> fetchedTasks =
          snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).where((
            task,
          ) {
            List assignedIds = task['assignedToEmployeeIds'] ?? [];
            return assignedIds.any((id) => id.split('_')[0] == user.email);
          }).toList();

      print(fetchedTasks.length);
      // Determine the latest step for each task
      for (var task in fetchedTasks) {
        List<dynamic> workflow = task['workflow'] ?? [];

        if (workflow.isNotEmpty) {
          workflow.sort((a, b) {
            Timestamp aTimestamp = a['updatedAt'] ?? Timestamp(0, 0);
            Timestamp bTimestamp = b['updatedAt'] ?? Timestamp(0, 0);
            return bTimestamp.compareTo(aTimestamp);
          });

          task['latestStep'] = workflow.first['step'];
        } else {
          task['latestStep'] = "TODO";
        }
      }

      // After setting latestStep for each task
      reworkTasks =
          fetchedTasks.where((task) => task['rework'] == true).toList();

      todoTasks =
          fetchedTasks
              .where(
                (task) =>
                    task['latestStep'] == "TODO" && task['rework'] != true,
              )
              .toList();

      inProgressTasks =
          fetchedTasks
              .where(
                (task) =>
                    task['latestStep'] == "IN PROGRESS" &&
                    task['rework'] != true,
              )
              .toList();

      doneTasks =
          fetchedTasks
              .where(
                (task) =>
                    task['latestStep'] == "DONE" && task['rework'] != true,
              )
              .toList();
    } catch (e) {
      print("Error fetching project tasks: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDetailedTaskStatus(String id, String status) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('detailed_tasks')
              .where('detailedTaskId', isEqualTo: id)
              .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentReference taskRef = snapshot.docs.first.reference;

        int progress;
        switch (status.toUpperCase()) {
          case 'TODO':
            progress = 0;
            break;
          case 'IN PROGRESS':
            progress = 40;
            break;
          case 'DONE':
            progress = 80;
            break;
          case 'SUBMITTED':
            progress = 100;
            break;
          default:
            progress = 0;
        }

        await taskRef.update({'progress': progress});
      }
    } catch (e) {
      print("Error updating task status: $e");
    }
  }

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

  Future<void> fetchAssignedProjects() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Step 1: Get all detailed tasks
      QuerySnapshot detailedTasksSnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('detailed_tasks')
              .get();

      // Step 2: Filter tasks assigned to current user and collect projectIds
      Set<String> assignedProjectIds = {};

      for (var doc in detailedTasksSnapshot.docs) {
        Map<String, dynamic> task = doc.data() as Map<String, dynamic>;
        List assignedIds = task['assignedToEmployeeIds'] ?? [];

        bool isAssigned = assignedIds.any(
          (id) => id.split('_')[0] == user.email,
        );

        if (isAssigned && task.containsKey('projectId')) {
          assignedProjectIds.add(task['projectId']);
        }
      }

      // Step 3: Fetch corresponding projects using projectId list
      List<Map<String, dynamic>> fetchedProjects = [];

      if (assignedProjectIds.isNotEmpty) {
        QuerySnapshot projectsSnapshot =
            await FirebaseFirestore.instance
                .collection('Projects')
                .where(
                  FieldPath.documentId,
                  whereIn: assignedProjectIds.toList(),
                )
                .get();

        for (var doc in projectsSnapshot.docs) {
          Map<String, dynamic> projectData = doc.data() as Map<String, dynamic>;
          projectData['projectId'] = doc.id;
          fetchedProjects.add(projectData);
          await updateProjectProgress(projectData['projectId']);
        }
      }

      // Step 4: You can store this in a notifier variable like `assignedProjects`
      assignedProjects = fetchedProjects;
      isLoading = false;
      notifyListeners();
      print("Fetched Assigned Projects: ${fetchedProjects.length}");
    } catch (e) {
      print("Error fetching assigned projects: $e");
    }
  }
}
