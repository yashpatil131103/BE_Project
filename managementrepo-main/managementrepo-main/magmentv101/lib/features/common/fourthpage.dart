//STilll much work to do on image picker and the data of manager to show and option to edit also
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:magmentv101/notifiers/user_notifier.dart';

import 'package:provider/provider.dart';

class FourthPage extends StatefulWidget {
  const FourthPage({super.key});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  final textStyle = GoogleFonts.quicksand(
    fontWeight: FontWeight.w700,
    fontSize: 15,
  );
  String _getDesignation(int? designation) {
    if (designation == null) {
      return 'Error: 101'; // Handle null case
    }

    switch (designation) {
      case 1:
        return 'Manager';
      case 2:
        return 'Team Lead';
      case 3:
        return 'Employee';
      default:
        return 'Unknown'; // Handle unexpected values
    }
  }

  @override
  Widget build(BuildContext context) {
    Map? userData = Provider.of<UserNotifier>(context).userData;

    UserNotifier loginprovider = Provider.of<UserNotifier>(context);
    String useranme = userData!["name"];
    String avatarUrl = "https://robohash.org/$useranme";

    return Scaffold(
      body:
      //Consumer<LoginProvider>(
      //builder: (context, loginProvider, child) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image and title
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 40); // default icon
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Details
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Name: ${userData!["name"]}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Email id: ${userData["id"]}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Designation:  ${userData["type"]}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "${userData["additionalInfo"]}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),
                // GestureDetector(
                //   onTap: () {
                //     showModalBottomSheet(
                //         context: context,
                //         // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
                //         builder: (BuildContext) {
                //           return SingleChildScrollView(
                //             child: Padding(
                //               padding: EdgeInsets.only(
                //                 bottom: MediaQuery.of(context).viewInsets.bottom,
                //               ),
                //               child: Column(
                //                 mainAxisSize: MainAxisSize.min,
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   Text(
                //                     "Update password",
                //                     style: const TextStyle(
                //                       fontWeight: FontWeight.w800,
                //                       fontSize: 22,
                //                     ),
                //                   ),
                //                   const SizedBox(height: 20),
                //                   Column(
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     children: [
                //                       Text("Password", style: textStyle),
                //                       const SizedBox(height: 5),
                //                       TextField(
                //                         controller: controller,
                //                         decoration: textFieldDecoration,
                //                       ),
                //                       const SizedBox(height: 10),
                //                     ],
                //                   ),
                //                   const SizedBox(height: 10),
                //                   ElevatedButton(
                //                     onPressed: () {
                //                       Provider.of<LoginProvider>(context,
                //                               listen: false)
                //                           .setUserregter(User(
                //                               email: loginprovider.user!.email,
                //                               password: controller.text,
                //                               name: loginprovider.user!.name,
                //                               designation:
                //                                   loginprovider.user!.designation,
                //                               empid: loginprovider.user!.empid));
                //                       Navigator.of(context).pop();
                //                     },
                //                     style: ButtonStyle(
                //                       backgroundColor: WidgetStatePropertyAll(
                //                           Theme.of(context)
                //                               .colorScheme
                //                               .secondary),
                //                     ),
                //                     child: Text(
                //                       "Submit",
                //                       style: TextStyle(
                //                           fontWeight: FontWeight.w800,
                //                           fontSize: 22,
                //                           color: Theme.of(context)
                //                               .colorScheme
                //                               .inversePrimary),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           );
                //         });
                //   },
                //   child: Container(
                //       padding: const EdgeInsets.all(5),
                //       // margin: const EdgeInsets.symmetric(horizontal: 50),
                //       decoration: BoxDecoration(
                //           color: Theme.of(context).colorScheme.secondary,
                //           borderRadius: BorderRadius.circular(7.0)),
                //       child: Text("Change password",
                //           style: TextStyle(
                //               fontSize: 20,
                //               fontWeight: FontWeight.bold,
                //               color:
                //                   Theme.of(context).colorScheme.inversePrimary))),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
