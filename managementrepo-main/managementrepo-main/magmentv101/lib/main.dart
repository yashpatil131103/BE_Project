import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:magmentv101/notifiers/user_notifier.dart';

import 'package:provider/provider.dart';
import 'package:magmentv101/constants/app_theme.dart';
import 'package:magmentv101/features/auth/login_page.dart';
import 'package:magmentv101/notifiers/employee_notifier.dart';
import 'package:magmentv101/notifiers/manager_notifier.dart';
import 'package:magmentv101/notifiers/project_details_notifier.dart';
import 'package:magmentv101/notifiers/teamLead_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyDdNVS1sJpDr4AxVvhpvx4smkA01TzDl8s',
        appId: '1:792195229692:android:9b6bec54d859a8e9f23479',
        messagingSenderId: '792195229692',
        projectId: 'flowpluschat',
      ),
    );
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ManagerNotifier()),
          ChangeNotifierProvider(create: (_) => ProjectDetailsNotifier()),
          ChangeNotifierProvider(create: (_) => TeamleadNotifier()),
          ChangeNotifierProvider(create: (_) => EmployeeNotifier()),
          ChangeNotifierProvider(create: (_) => UserNotifier()),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
