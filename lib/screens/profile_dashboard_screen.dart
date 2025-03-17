import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/user_form.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Widgets/header.dart';
import 'home_screen.dart';
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
  Timer? _timer; // Timer to schedule notifications

  @override
  void initState() {
    super.initState();
    // Schedule the overlay notification every 30 seconds.
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _showProfileCompletionNotification();
      }
    });
  }

  // Insert a custom overlay entry that slides from the top.
  void _showProfileCompletionNotification() {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => CustomNotification(
        profileCompletion: _profileCompletionPercentage.toInt(),
        onClose: () {
          overlayEntry?.remove();
        },
      ),
    );
    Overlay.of(context)?.insert(overlayEntry);
  }

  // Request permission and pick profile image from gallery.
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

  // Request permission and pick background image from gallery.
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
  void dispose() {
    // Cancel the timer when disposing the widget.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Custom AppBar using GuideraHeader with a back button.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            Positioned(
              top: 70,
              left: 10,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/back.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Fallback: navigate to a default screen (e.g., HomeScreen)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            // Background and profile picture combined into one Stack.
            Stack(
              clipBehavior: Clip.none,
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
                // Background image edit icon
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
                // Circular DP overlapping the bottom edge of the background.
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.lightBlack,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage('assets/images/user_profile.jpg')
                          as ImageProvider,
                        ),
                        // DP edit icon
                        Positioned(
                          bottom: -5,
                          right: -5,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60), // Space to account for overlap.
            // User Name.
            Text(
              "Saad Mahmood",
              style: TextStyle(
                color: AppColors.myWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // User Email.
            Text(
              "saad.mhmoood@gmail.com",
              style: TextStyle(
                color: AppColors.myGray,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            // Profile Details Section.
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
            // About Me Section.
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
            // Edit Info Button.
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileCompletionScreen()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Logout Button.
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

// Custom overlay notification widget that slides in from the top.
class CustomNotification extends StatefulWidget {
  final int profileCompletion;
  final VoidCallback onClose;

  const CustomNotification({
    Key? key,
    required this.profileCompletion,
    required this.onClose,
  }) : super(key: key);

  @override
  _CustomNotificationState createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    // Animation controller for slide transition.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();

    // Auto-dismiss after 10 seconds.
    Future.delayed(const Duration(seconds: 10), () {
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Position it below the status bar.
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            // Dismiss on tap.
            onTap: widget.onClose,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Profile Completion: ${widget.profileCompletion}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
