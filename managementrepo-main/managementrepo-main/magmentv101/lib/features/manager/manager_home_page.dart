import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:magmentv101/constants/app_theme.dart';
import 'package:magmentv101/features/auth/login_page.dart';
import 'package:magmentv101/features/common/fourthpage.dart';
import 'package:magmentv101/features/common/secondpage.dart';
import 'package:magmentv101/features/manager/add_project_page.dart';
import 'package:magmentv101/features/manager/project_details_page.dart';
import 'package:magmentv101/notifiers/manager_notifier.dart';
import 'package:magmentv101/widgets/mydrawer.dart';
import 'package:magmentv101/widgets/project_card.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ManagerHomePage extends StatelessWidget {
  final String managerId;

  const ManagerHomePage({super.key, required this.managerId});

  TabBarView changethetabpage() {
    return TabBarView(
      children: [
        Consumer<ManagerNotifier>(
          builder: (context, notifier, _) {
            return RefreshIndicator(
              onRefresh: () async {
                await notifier.fetchProjects(managerId);
              },
              child:
                  notifier.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notifier.projects.isEmpty
                      ? const Center(child: Text('No projects found.'))
                      : ListView.builder(
                        itemCount: notifier.projects.length,
                        itemBuilder: (context, index) {
                          final project = notifier.projects[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProjectDetailsPage(
                                          projectId: project.projectId,
                                        ),
                                  ),
                                );
                              },
                              child: ProjectCard(project: project),
                            ),
                          );
                        },
                      ),
            );
          },
        ),
        SecondPage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManagerNotifier()..fetchProjects(managerId),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Column(
              children: [
                Text(
                  "Manager",
                  style: AppTheme.headlineTextStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manager',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            backgroundColor: AppTheme.primaryColor,
            bottom: TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.business)),
              ],
            ),
          ),
          drawer: MyDrawer(
            widget: ManagerHomePage(managerId: "WqMPmohpEhUvNWemvWkNnoWY4rD2"),
          ),
          body: changethetabpage(),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'fab1', // Use unique heroTag for each FAB
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProjectPage()),
                  );
                },
                child: Icon(Icons.add),
              ),
            ],
          ), //Navigator.push(
          //context,
          //MaterialPageRoute(builder: (context) => AddProjectPage()),

          // Edit action
        ),
      ),
    );
  }
}
