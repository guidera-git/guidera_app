import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/user_form.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'login-signup.dart';


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _profileImage;
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();
  double _profileCompletionPercentage = 80.0; // For demo purposes

  // Request permission and pick profile image from gallery
  Future<void> _pickProfileImage() async {
    var permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } else {
      debugPrint("Photo permission not granted for profile image.");
    }
  }

  // Request permission and pick background image from gallery
  Future<void> _pickBackgroundImage() async {
    var permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _backgroundImage = File(pickedFile.path);
        });
      }
    } else {
      debugPrint("Photo permission not granted for background image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlack,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.myWhite),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.myWhite),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/edit.svg',
              color: AppColors.myWhite,
              height: 25,
            ),
            onPressed: () {
              // TODO: Navigate to the edit profile screen if desired
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Background section with edit button
                Stack(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        image: _backgroundImage != null
                            ? DecorationImage(
                          image: FileImage(_backgroundImage!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                    ),
                    // Background edit icon (positioned like WhatsApp)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: _pickBackgroundImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Profile picture section with WhatsApp-like edit icon
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightBlack,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/images/user_profile.jpg')
                      as ImageProvider,
                    ),
                    // Profile picture edit icon positioned bottom-right
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green, // WhatsApp-like green
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                // User Name
                Text(
                  "John Doe", // Replace with dynamic user data
                  style: TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // User Email
                Text(
                  "john.doe@example.com", // Replace with dynamic user data
                  style: TextStyle(
                    color: AppColors.myGray,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),

                // Profile Details Section
                // (Removed University, Program, and Contact)
                // Keeping only Gender and Birthdate for demonstration
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildProfileDetailItem(
                        icon: Icons.person,
                        title: "Gender",
                        value: "Male",
                      ),
                      const Divider(color: AppColors.lightBlack, thickness: 1),
                      _buildProfileDetailItem(
                        icon: Icons.calendar_today,
                        title: "Birthdate",
                        value: "January 1, 2000",
                      ),
                      const Divider(color: AppColors.lightBlack, thickness: 1),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // About Me Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About Me",
                        style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "A motivated student pursuing software engineering with a passion for technology, research, and continuous learning. Eager to explore opportunities in data science, machine learning, and AI.",
                        style: TextStyle(
                          color: AppColors.myGray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Edit Info Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, color: AppColors.myWhite),
                      label: const Text(
                        "Edit Info",
                        style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Navigate to user_form.dart
                        // For example:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileCompletionScreen()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: AppColors.myWhite),
                      label: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Implement logout logic
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginSignup()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Profile completion overlay
          Positioned(
            top: 130,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, color: AppColors.darkBlue),
                  const SizedBox(width: 10),
                  Text(
                    "Profile Completion: ${_profileCompletionPercentage.toInt()}%",
                    style: const TextStyle(
                      color: AppColors.myWhite,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build each profile detail row.
  Widget _buildProfileDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkBlue, size: 24),
          const SizedBox(width: 10),
          Text(
            "$title:",
            style: const TextStyle(
              color: AppColors.myWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.myGray,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
