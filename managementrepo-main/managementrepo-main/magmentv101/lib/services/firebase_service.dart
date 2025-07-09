import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magmentv101/features/auth/model/user_model.dart';
import 'package:magmentv101/models/project_model.dart';
import 'dart:math'; // Import for random ID generation

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
    required String additionalInfo,
    required String profileColor,
  }) async {
    try {
      // Register user in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user model
      UserModel newUser = UserModel(
        id: email,
        type: userType,
        name: name,
        email: email,
        phone: phone,
        password: password,
        isActive: true,
        additionalInfo: additionalInfo,
        profileColor: profileColor,
      );

      await _firestore.collection('users').doc(email).set(newUser.toMap());

      return newUser;
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }

  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in user with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user ID
      String userId = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(email).get();

      if (userDoc.exists) {
        // Convert Firestore document to UserModel
        UserModel loggedInUser = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
        );

        return loggedInUser;
      } else {
        // print("User not found in Firestore.");
        return null;
      }
    } catch (e) {
      // print("Error logging in user: $e");
      return null;
    }
  }

  // static Future<UserModel> loggedInUser() async {
  //   String? patientId = FirebaseAuth.instance.currentUser?.uid;
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(patientId)
  //       .get();
  //   UserModel loggedInUser =
  //       UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  //   return loggedInUser;
  // }

  static Future<void> addProject(ProjectModel project) async {
    try {
      // Generate a short random alphanumeric project ID
      String generatedProjectId = _generateShortId();

      // Create a new ProjectModel with the generated ID
      ProjectModel projectWithId = ProjectModel(
        projectId: generatedProjectId,
        name: project.name,
        dueDate: project.dueDate,
        managerId: project.managerId,
        teamLeadId: project.teamLeadId,
        description: project.description,
        createdAt: Timestamp.now(),
        progress: 0,
        status: 'Active',
        departmentId: project.departmentId,
        // tasks: project.tasks,
      );

      // Store project data in Firestore
      await _firestore
          .collection('Projects')
          .doc(generatedProjectId)
          .set(projectWithId.toMap());
    } catch (e) {
      throw Exception('Failed to add project: $e');
    }
  }

  // Helper method to generate a short random alphanumeric ID
  static String _generateShortId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  static Future<List<ProjectModel>> getProjectsByManager(
    String managerId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Projects').get();

      return snapshot.docs
          .map(
            (doc) => ProjectModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTeamLeads() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('type', isEqualTo: 'TeamLead')
              .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, 'name': doc['name'] ?? ''};
      }).toList();
    } catch (e) {
      print("Error fetching team leads: $e");
      return [];
    }
  }

  static Future<String> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email)
              .get();

      return userDoc.exists ? userDoc['name'] ?? "User" : "Unknown User";
    }
    return "Unknown User"; // Default return value if user is null
  }

  static Future<List<Map<String, dynamic>>> getEmployess() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('type', isEqualTo: 'Employee')
              .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? '',
          // 'profileColor': doc['profileColor'] ?? '',
          'email': doc['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching team leads: $e");
      return [];
    }
  }

  Future<String> fetchProjectName(String projectId) async {
    try {
      DocumentSnapshot projectSnapshot =
          await FirebaseFirestore.instance
              .collection('Projects')
              .doc(projectId)
              .get();

      if (projectSnapshot.exists) {
        return projectSnapshot['name'] ?? 'Unknown Project';
      }
    } catch (e) {
      print("Error fetching project name: $e");
    }
    return 'Unknown Project';
  }

  Future<String> fetchTeamLeadName(String teamLeadId) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(teamLeadId)
              .get();

      if (userSnapshot.exists) {
        return userSnapshot['name'] ?? 'Unknown Team Lead';
      }
    } catch (e) {
      print("Error fetching team lead name: $e");
    }
    return 'Unknown Team Lead';
  }
}
