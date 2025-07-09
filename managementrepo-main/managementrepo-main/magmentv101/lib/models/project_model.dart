import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  String projectId;
  String name;
  String description;
  String managerId;
  String departmentId;
  Timestamp createdAt;
  String dueDate;
  int progress;
  String status;
  String teamLeadId;

  ProjectModel({
    required this.projectId,
    required this.name,
    required this.description,
    required this.managerId,
    required this.departmentId,
    required this.createdAt,
    required this.dueDate,
    required this.progress,
    required this.status,
    required this.teamLeadId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'name': name,
      'description': description,
      'managerId': managerId,
      'departmentId': departmentId,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'progress': progress,
      'status': status,
      'teamLeadId': teamLeadId,
    };
  }

  // Create a ProjectModel from Firestore document
  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      projectId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      managerId: map['managerId'] ?? '',
      departmentId: map['departmentId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      dueDate: map['dueDate'] ?? Timestamp.now(),
      progress: map['progress'] ?? 0,
      status: map['status'] ?? 'Active',
      teamLeadId: map['teamLeadId'] ?? '', // Added teamLeadId
    );
  }
}
