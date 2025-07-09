import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magmentv101/services/firebase_service.dart';

class TeamleadNotifier extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, dynamic>> tasks = [];

  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> todoSteps = [];
  List<Map<String, dynamic>> submittedSteps = [];
  List<Map<String, dynamic>> doneSteps = [];
  List<Map<String, dynamic>> reworkSteps = [];

  bool showTasks = true;
  Map<String, dynamic> workflowDetails = {};
  bool isLoadingWorkflow = true;

  //   Future<void> fetchWorkflow(Map<String, dynamic> task) async {
  //   // Clear previous workflow data
  //   todoSteps.clear();
  //   submittedSteps.clear();
  //   doneSteps.clear();
  //   reworkSteps.clear();
  //   isLoadingWorkflow = true;
  //   notifyListeners();

  //   final fetchedWorkflow = await fetchTaskWorkflow(task['detailedTaskId']);
  //   workflowDetails = fetchedWorkflow;
  //   isLoadingWorkflow = false;

  //   // Cast workflow to List<Map<String, dynamic>>
  //   final List<Map<String, dynamic>> workflowList =
  //       List<Map<String, dynamic>>.from(workflowDetails['workflow'] ?? []);

  //   if (task['rework'] == false && task['taskCompleted'] == false) {
  //     todoSteps = workflowList
  //         .where((step) => step['step'] == 'TODO' || step['step'] == 'IN PROGRESS')
  //         .toList();
  //   }

  //   if (task['taskCompleted'] == false && task['rework'] == false) {
  //     submittedSteps = workflowList.where((step) => step['step'] == 'DONE').toList();
  //   }

  //   if (task['taskCompleted'] == true && task['rework'] == false) {
  //     doneSteps = workflowList.where((step) => step['step'] == 'DONE').toList();
  //   }

  //   if (task['rework'] == true) {
  //     reworkSteps = workflowList.where((step) => step['step'] == 'DONE').toList();
  //   }

  //   notifyListeners();
  // }

  Future<void> fetchWorkflow(Map<String, dynamic> task) async {
    // Clear previous workflow data
    todoSteps.clear();
    submittedSteps.clear();
    doneSteps.clear();
    reworkSteps.clear();
    isLoadingWorkflow = true;
    notifyListeners();

    final fetchedWorkflow = await fetchTaskWorkflow(task['detailedTaskId']);

    workflowDetails = fetchedWorkflow;
    isLoadingWorkflow = false;

    // Populate workflow steps
    if (task['rework'] == false && task['taskCompleted'] == false) {
      todoSteps =
          workflowDetails['workflow']
              .where(
                (step) =>
                    step['step'] == 'TODO' || step['step'] == 'IN PROGRESS',
              )
              .toList();
    }

    if (task['taskCompleted'] == false && task['rework'] == false) {
      submittedSteps =
          workflowDetails['workflow']
              .where((step) => step['step'] == 'DONE')
              .toList();
    }

    if (task['taskCompleted'] == true && task['rework'] == false) {
      doneSteps =
          workflowDetails['workflow']
              .where((step) => step['step'] == 'DONE')
              .toList();
    }
    if (task['rework'] == true) {
      reworkSteps =
          workflowDetails['workflow']
              .where((step) => step['step'] == 'DONE')
              .toList();
    }

    notifyListeners();
  }

  Future<void> updateAbstractTaskProgress(
    String projectId,
    String abstractTaskId,
  ) async {
    try {
      // Get all detailed_tasks under the specific abstract task
      QuerySnapshot detailedTasksSnapshot =
          await FirebaseFirestore.instance
              .collection('Projects')
              .doc(projectId)
              .collection('abstractTasks')
              .doc(abstractTaskId)
              .collection('detailed_tasks')
              .get();

      final docs = detailedTasksSnapshot.docs;

      if (docs.isNotEmpty) {
        // Sum up all the progress values
        int totalProgress = 0;
        int count = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final progress = data['progress'];

          if (progress != null) {
            totalProgress +=
                (progress is int)
                    ? progress
                    : int.tryParse(progress.toString()) ?? 0;
            count++;
          }
        }

        int averageProgress = count > 0 ? (totalProgress ~/ count) : 0;

        // Update the abstract task with this average progress
        await FirebaseFirestore.instance
            .collection('Projects')
            .doc(projectId)
            .collection('abstractTasks')
            .doc(abstractTaskId)
            .update({'progress': averageProgress});
      }
    } catch (e) {
      print("Error updating abstract task progress: $e");
    }
  }

  void fetchEmployess() async {
    try {
      employees = await FirebaseService.getEmployess();
      print("✅ Employees fetched: ${employees.length}");
      notifyListeners();
    } catch (e) {
      print("Error fetching team leads: $e");
    }
  }

  Future<void> markDetailedTaskAsDone(String id, Map<String, bool> map) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('detailed_tasks')
              .where('detailedTaskId', isEqualTo: id)
              .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentReference taskRef = snapshot.docs.first.reference;

        await taskRef.update({'taskCompleted': true});
      }
    } catch (e) {
      print("Error fetching task workflow: $e");
    }
  }

  Future<void> raiseTicket(String id, Map<String, dynamic> map) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('detailed_tasks')
              .where('detailedTaskId', isEqualTo: id)
              .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentReference taskRef = snapshot.docs.first.reference;

        await taskRef.update({
          'rework': true,
          'reworkReason': map['reworkReason'],
        });
      }
    } catch (e) {
      print("Error fetching task workflow: $e");
    }
  }

  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();

    try {
      // Get current user ID from Firebase Authentication
      String? currentUserId = FirebaseAuth.instance.currentUser?.email;
      if (currentUserId == null) {
        print("❌ No authenticated user found.");
        return;
      }

      // Fetch projects where the teamLeadId contains the user ID
      QuerySnapshot projectSnapshot =
          await FirebaseFirestore.instance
              .collection('Projects')
              .where('teamLeadId', isGreaterThanOrEqualTo: "")
              .get();

      List<String> projectIds = [];

      for (var project in projectSnapshot.docs) {
        String teamLeadId = project['teamLeadId'] ?? '';
        String extractedId = teamLeadId.split('_').last; // Extract ID part
        print(extractedId);
        print(currentUserId);
        if (extractedId == currentUserId) {
          projectIds.add(project.id);
        }
      }

      print("✅ Found ${projectIds.length} projects for the team lead.");

      // Fetch tasks from the `abstractTasks` subcollection in those projects
      List<Map<String, dynamic>> fetchedTasks = [];

      for (String projectId in projectIds) {
        QuerySnapshot taskSnapshot =
            await FirebaseFirestore.instance
                .collection('Projects')
                .doc(projectId)
                .collection('abstractTasks')
                .get();

        for (var task in taskSnapshot.docs) {
          fetchedTasks.add(task.data() as Map<String, dynamic>);
        }
      }

      tasks = fetchedTasks;

      final snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('abstractTasks')
              .get();

      tasks = snapshot.docs.map((doc) => doc.data()).toList();

      // After fetching, update each abstract task's progress
      for (var task in tasks) {
        final projectId = task['projectId'];
        final abstractTaskId = task['task_id'];
        if (projectId != null && abstractTaskId != null) {
          await updateAbstractTaskProgress(projectId, abstractTaskId);
        }
      }
      print("✅ Total tasks fetched: ${tasks.length}");
    } catch (e) {
      print("❌ Error fetching tasks: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchTaskWorkflow(String taskId) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('detailed_tasks')
              .where('detailedTaskId', isEqualTo: taskId)
              .get();

      if (snapshot.docs.isNotEmpty) {
        var taskData = snapshot.docs.first.data() as Map<String, dynamic>;
        List<dynamic> workflow = taskData['workflow'] ?? [];

        List<Map<String, dynamic>> formattedWorkflow =
            workflow.map((entry) {
              Map<String, dynamic> workflowEntry = {
                'step': entry['step'] ?? 'UNKNOWN',
                'updatedAt': entry['updatedAt']?.toDate() ?? DateTime.now(),
                'githubUrl': entry['githubUrl'] ?? '',
              };

              if (entry.containsKey('updatedBy')) {
                workflowEntry['updatedBy'] = entry['updatedBy'];
              }

              return workflowEntry;
            }).toList();

        return {
          'taskId': taskData['detailedTaskId'] ?? '',
          'taskTitle': taskData['title'] ?? 'Untitled Task',
          'taskDescription': taskData['description'] ?? 'No description',
          'status': taskData['status'] ?? 'TODO',
          'workflow': formattedWorkflow,
        };
      }
    } catch (e) {
      print("Error fetching task workflow: $e");
    }

    return {
      'taskId': '',
      'taskTitle': 'Untitled Task',
      'taskDescription': 'No description',
      'status': 'TODO',
      'workflow': [],
    };
  }
}
