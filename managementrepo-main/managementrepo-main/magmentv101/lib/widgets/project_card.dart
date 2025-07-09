import 'package:flutter/material.dart';
import 'package:magmentv101/models/project_model.dart';
import 'package:magmentv101/widgets/completion_status_bar.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project.departmentId,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  project.projectId,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),

            // const Divider(height: 20, thickness: 1),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           project.status,
            //           style: const TextStyle(
            //               fontSize: 18, fontWeight: FontWeight.bold),
            //         ),
            //         const SizedBox(height: 4),
            //         Text("Status",
            //             style:
            //                 TextStyle(color: Colors.grey[600], fontSize: 14)),
            //       ],
            //     ),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         Text(
            //           "${project.progress.toInt()}%",
            //           style: const TextStyle(
            //               fontSize: 18, fontWeight: FontWeight.bold),
            //         ),
            //         const SizedBox(height: 4),
            //         Text("Progress",
            //             style:
            //                 TextStyle(color: Colors.grey[600], fontSize: 14)),
            //       ],
            //     ),
            //   ],
            // ),
            const Divider(height: 20, thickness: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Due Date",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.dueDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Team Lead",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.teamLeadId.split('_')[0],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 20, thickness: 1),

            // Progress bar
            CompletionStatusBar(progress: project.progress),

            const SizedBox(height: 10),
            // const Divider(height: 20, thickness: 1),

            // const Text("Description",
            //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 4),
            // Text(
            //   project.description.isNotEmpty
            //       ? project.description
            //       : "No description provided",
            //   style: TextStyle(color: Colors.grey[700]),
            // ),
          ],
        ),
      ),
    );
  }
}
