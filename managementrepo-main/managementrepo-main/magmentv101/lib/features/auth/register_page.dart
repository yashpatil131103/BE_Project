import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:magmentv101/constants/app_theme.dart';
import 'package:magmentv101/constants/constants.dart';
import 'package:magmentv101/features/auth/model/user_model.dart';
import 'package:magmentv101/services/firebase_service.dart';
import 'package:magmentv101/widgets/snackbar_helper.dart';
import 'package:magmentv101/widgets/custom_textfield.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserType? selectedUserType = UserType.TeamLead;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController skillSetController = TextEditingController();
  TextEditingController numEmployeesController = TextEditingController();
  String? selectedDomain;
  String? selectedTeamLead;
  String? selectedSkill;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> teamLeads =
      []; // Updated to store fetched team leads
  Color selectedColor = Colors.blue; // Default color

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pick a Profile Color"),
          content: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() => selectedColor = color);
            },
            availableColors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.pink,
              Colors.teal,
              Colors.cyan,
              Colors.amber,
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Select"),
            ),
          ],
        );
      },
    );
  }

  final List<String> organizationDomains = [
    'IT & Software Development',
    'Healthcare & Pharmaceuticals',
    'Education & Training',
    'Finance & Banking',
    'E-commerce & Retail',
    'Manufacturing & Production',
    'Marketing & Advertising',
    'Real Estate & Construction',
    'Telecommunications',
    'Logistics & Supply Chain',
  ];

  final List<String> skills = [
    'Flutter',
    'React',
    'Node.js',
    'Python',
    'Machine Learning',
    'Project Management',
    'Cybersecurity',
    'Cloud Computing',
    'Add New Skill...',
  ];

  @override
  void initState() {
    super.initState();
    fetchTeamLeads();
  }

  Future<void> fetchTeamLeads() async {
    try {
      final fetchedTeamLeads = await FirebaseService.getTeamLeads();
      setState(() {
        teamLeads = fetchedTeamLeads;
      });
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        "Failed to fetch team leads: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  SizedBox(height: 60),
                  // _buildLogo(),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickColor,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: selectedColor,
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Tap to pick color"),
                  SizedBox(height: 20),
                  _buildUserTypeSelector(),
                  SizedBox(height: 40),
                  _buildRegistrationForm(),
                  SizedBox(height: 30),
                  _buildLoginLink(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: AppTheme.bodyTextStyle.copyWith(color: Colors.white),
          children: [
            TextSpan(text: 'Login here', style: AppTheme.linkTextStyle),
          ],
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
        Text('TaskFlow', style: AppTheme.headlineTextStyle),
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Column(
      children: [
        Text(
          'Select Your Role',
          style: AppTheme.subtitleTextStyle.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUserRoleOption(
                userType: UserType.TeamLead,
                label: "Team Lead",
                icon: Icons.supervisor_account,
              ),
              _buildUserRoleOption(
                userType: UserType.Employee,
                label: "Employee",
                icon: Icons.person,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserRoleOption({
    required UserType userType,
    required String label,
    required IconData icon,
  }) {
    bool isSelected = selectedUserType == userType;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserType = userType;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppTheme.iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyTextStyle.copyWith(
                color: isSelected ? Colors.white : AppTheme.iconColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildInputField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your name';
            }
            List<String> words = value.trim().split(' ');

            for (var word in words) {
              if (!RegExp(r'^[a-zA-Z]+$').hasMatch(word)) {
                return 'Only alphabets (uppercase and lowercase) are allowed';
              }
            }
            return null;
          },
          controller: nameController,
          hint: 'Full Name',
          icon: Icons.person,
        ),
        SizedBox(height: 20),
        _buildInputField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          controller: emailController,
          hint: 'Email Address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20),
        _buildInputField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Enter a valid 10-digit phone number';
            }
            return null;
          },
          controller: phoneController,
          hint: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 20),
        if (selectedUserType == UserType.TeamLead) _buildDomainDropdown(),
        if (selectedUserType == UserType.Employee) ...[
          _buildTeamLeadDropdown(),
          SizedBox(height: 20),
          _buildSkillSetDropdown(),
        ],
        SizedBox(height: 20),
        _buildInputField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          controller: passwordController,
          hint: 'Password',
          icon: Icons.lock,
          obscureText: true,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          style: AppTheme.elevatedButtonStyle,
          onPressed: registerUser,
          child:
              isLoading
                  ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text('CREATE ACCOUNT', style: AppTheme.buttonTextStyle),
        ),
      ],
    );
  }

  Widget _buildDomainDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDomain,
      decoration: AppTheme.inputDecoration.copyWith(
        prefixIcon: Icon(Icons.supervisor_account, color: AppTheme.iconColor),
      ),
    
      items:
          organizationDomains
              .map(
                (domain) =>
                    DropdownMenuItem(value: domain, child: Text(domain,overflow: TextOverflow.ellipsis,)),
              )
              .toList(),
      onChanged: (value) => setState(() => selectedDomain = value),
      hint: Text('Select Domain',overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildTeamLeadDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedTeamLead,
      decoration: AppTheme.inputDecoration.copyWith(
        prefixIcon: Icon(Icons.supervisor_account, color: AppTheme.iconColor),
      ),
      items:
          teamLeads.map((lead) {
            return DropdownMenuItem(
              value: lead['id'] as String,
              child: Text(lead['name'] as String),
            );
          }).toList(),
      onChanged: (value) => setState(() => selectedTeamLead = value),
      hint: Text('Select Team Lead'),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required dynamic validator,
  }) {
    return CustomTextField(
      validator: (value) => validator,
      controller: controller,
      hintText: hint,
      icon: icon,
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }

  Widget _buildSkillSetDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedSkill,
      decoration: AppTheme.inputDecoration.copyWith(
        prefixIcon: Icon(Icons.build, color: AppTheme.iconColor),
      ),
      items:
          skills.map((skill) {
            return DropdownMenuItem(value: skill, child: Text(skill));
          }).toList(),
      onChanged: (value) {
        if (value == 'Add New Skill...') {
          _showAddSkillDialog();
        } else {
          setState(() => selectedSkill = value);
        }
      },
      hint: Text('Select Skill', style: AppTheme.inputTextStyle),
    );
  }

  void _showAddSkillDialog() {
    TextEditingController newSkillController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Skill"),
          content: TextField(
            controller: newSkillController,
            decoration: InputDecoration(hintText: "Enter skill name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String newSkill = newSkillController.text.trim();
                if (newSkill.isNotEmpty && !skills.contains(newSkill)) {
                  setState(() {
                    skills.insert(skills.length - 1, newSkill);
                    selectedSkill = newSkill;
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    UserModel? user = await FirebaseService.registerUser(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      password: passwordController.text,
      userType: selectedUserType.toString().split('.').last,
      additionalInfo:
          selectedUserType == UserType.TeamLead
              ? 'Domain: $selectedDomain'
              : 'Team Lead: $selectedTeamLead, Skill: $selectedSkill',
      profileColor: selectedColor.value.toRadixString(16),
    );

    if (user != null) {
      SnackBarHelper.showSnackBar(
        context,
        "User registered successfully!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } else {
      SnackBarHelper.showSnackBar(
        context,
        "User registration failed. Try again!",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    setState(() => isLoading = false);
  }
}
