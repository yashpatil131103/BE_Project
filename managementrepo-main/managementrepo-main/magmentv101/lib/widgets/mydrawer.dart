import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:magmentv101/features/auth/login_page.dart';
import 'package:magmentv101/widgets/aboutpage.dart';
//import 'package:magmentv101/widgets/my_settingpage.dart';

// ignore: must_be_immutable
class MyDrawer extends StatelessWidget {
  final Widget widget;
  const MyDrawer({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    Widget pagetosend() {
      return widget;
    }

    return Drawer(
      backgroundColor: Colors.transparent,
      //Color.fromRGBO(222, 223, 225, 255),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 25),
              ClipOval(
                child: Image.asset(
                  "assets/jpg/logo.jpg",
                  width: 200,
                  height: 200,
                  fit:
                      BoxFit
                          .cover, // Adjusts the image to fit within the circle
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(blurRadius: 5.0)],
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.home),
                      SizedBox(width: 5.0),
                      Text(
                        "HOME ",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => pagetosend()),
                  );
                },
              ),
              // GestureDetector(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       boxShadow: [BoxShadow(blurRadius: 5.0)],
              //       color: Theme.of(context).colorScheme.tertiaryContainer,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     margin: const EdgeInsets.all(20),
              //     padding: const EdgeInsets.all(16),
              //     child: Row(
              //       children: [
              //         const Icon(Icons.settings),
              //         SizedBox(width: 5.0),
              //         Text(
              //           "Setting ",
              //           style: TextStyle(
              //             fontSize: 17,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => SettingsPage()),
              //     );
              //   },
              // ),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(blurRadius: 5.0)],
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.group),
                      SizedBox(width: 5.0),
                      Text(
                        "About Us ",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => aboutpage()),
                  );
                },
              ),
            ],
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: 5.0)],
                color: Theme.of(context).colorScheme.tertiaryFixedDim,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Color.fromARGB(255, 0, 0, 0)),
                  SizedBox(width: 5.0),
                  Text(
                    "LOGOUT ",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
