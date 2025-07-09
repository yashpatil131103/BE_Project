import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magmentv101/notifiers/user_notifier.dart';
import 'package:provider/provider.dart';
import 'package:magmentv101/constants/app_theme.dart';
import 'package:magmentv101/constants/constants.dart';
import 'package:magmentv101/features/auth/model/user_model.dart';
import 'package:magmentv101/features/auth/register_page.dart';
import 'package:magmentv101/features/employee/employee_home_page.dart';
import 'package:magmentv101/features/manager/manager_home_page.dart';

import 'package:magmentv101/features/teamlead/teamlead_home_page.dart';
import 'package:magmentv101/notifiers/teamLead_notifier.dart';
import 'package:magmentv101/services/firebase_service.dart';
import 'package:magmentv101/widgets/snackbar_helper.dart';
import 'package:magmentv101/widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserType? selectedUserType = UserType.Manager;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // gradient: AppTheme.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                _buildLogo(),
                SizedBox(height: 30),
                // _buildUserTypeSelector(),
                // SizedBox(height: 40),
                _buildLoginForm(),
                SizedBox(height: 30),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.task, size: 60, color: AppTheme.iconColor),
        ),
        SizedBox(height: 20),
        Text(
          'TaskFlow',
          style: AppTheme.headlineTextStyle.copyWith(
            // color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          CustomTextField(
            controller: emailController,
            hintText: 'Email',
            icon: Icons.email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          CustomTextField(
            controller: passwordController,
            hintText: 'Password',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }

              return null;
            },
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: AppTheme.elevatedButtonStyle,
            onPressed: _isLoading ? null : _handleLogin,
            child:
                _isLoading
                    ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text('SIGN IN', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      },
      child: RichText(
        text: TextSpan(
          text: 'New user ? ',
          style: AppTheme.bodyTextStyle.copyWith(color: Colors.blue),
          children: [
            TextSpan(text: 'Create account', style: AppTheme.linkTextStyle),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      SnackBarHelper.showSnackBar(
        context,
        "Please enter email and password.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Hardcoded Manager credentials
    const String managerEmail = "manager@cmp.com";
    const String managerPassword = "manager.cmp";

    if (emailController.text == managerEmail &&
        passwordController.text == managerPassword) {
      SnackBarHelper.showSnackBar(
        context,
        "Welcome, Manager!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ManagerHomePage(managerId: "WqMPmohpEhUvNWemvWkNnoWY4rD2"),
        ),
      );

      setState(() {
        _isLoading = false;
      });

      return;
    }

    // Dynamic authentication for other users
    UserModel? user = await FirebaseService.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    FirebaseFirestore firebaseFirestore = await FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> response =
        await firebaseFirestore
            .collection("users")
            .doc(emailController.text)
            .get();
    Map<String, dynamic>? userData = response.data();
    log('${userData}');
    Provider.of<UserNotifier>(context, listen: false).userData = userData;

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      SnackBarHelper.showSnackBar(
        context,
        "Welcome, ${user.name}!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      if (user.type == "TeamLead") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChangeNotifierProvider(
                  create: (_) => TeamleadNotifier()..fetchTasks(),
                  child: const TeamleadHomePage(),
                ),
          ),
        );
      } else if (user.type == "Employee") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmpHomePage()),
        );
      } else {
        SnackBarHelper.showSnackBar(
          context,
          "User type not yet supported.",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } else {
      SnackBarHelper.showSnackBar(
        context,
        "Invalid email or password.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
