import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as _secureStorage;
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

import '../Widgets/header.dart';
import 'home_screen.dart';
import 'login-signup.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  String? fullName;
  String email = '';
  String? _gender;
  DateTime? _birthdate;
  String? _aboutMe;
  String? _profilePhotoUrl;
  String? _backgroundPhotoUrl;
  File? _pickedProfile;
  File? _pickedBackground;
  bool _loading = true;
  bool _picking = false;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _api.getProfile();
      final data = jsonDecode(response.body);
      setState(() {
        fullName = data['fullname'];
        email = data['email'];
        _gender = data['gender'];
        _birthdate = data['birthdate'] != null ? DateTime.parse(data['birthdate']) : null;
        _aboutMe = data['aboutme'];
        _profilePhotoUrl = data['profilephoto'];
        _backgroundPhotoUrl = data['backgroundphoto'];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateField(Map<String, dynamic> data) async {
    await _api.updateProfile(data);
  }

  Future<void> _updateImageOnServer(File file, bool isProfile) async {
    final resp = isProfile
        ? await _api.uploadProfilePhoto(file)
        : await _api.uploadBackgroundPhoto(file);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      setState(() {
        if (isProfile) {
          _profilePhotoUrl = body['profilephoto'];
        } else {
          _backgroundPhotoUrl = body['backgroundphoto'];
        }
      });
    }
  }

  Future<void> _deleteProfilePhoto() async {
    final resp = await _api.deleteProfilePhoto();
    if (resp.statusCode == 200) {
      setState(() {
        _profilePhotoUrl = null;
        _pickedProfile = null;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _picking = true);
      _pickedProfile = File(picked.path);
      await _updateImageOnServer(_pickedProfile!, true);
      setState(() => _picking = false);
    }
  }

  Future<void> _pickBackgroundImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _picking = true);
      _pickedBackground = File(picked.path);
      await _updateImageOnServer(_pickedBackground!, false);
      setState(() => _picking = false);
    }
  }

  void _showProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.visibility, color: AppColors.textPrimary(context)),
            title: Text('View', style: TextStyle(color: AppColors.textPrimary(context))),
            onTap: () {
              Navigator.pop(context);
              _showFullScreenImage();
            },
          ),
          ListTile(
            leading: Icon(Icons.edit, color: AppColors.textPrimary(context)),
            title: Text('Edit', style: TextStyle(color: AppColors.textPrimary(context))),
            onTap: () {
              Navigator.pop(context);
              _pickProfileImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteProfilePhoto();
            },
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage() {
    final profileImage = _pickedProfile != null
        ? FileImage(_pickedProfile!)
        : (_profilePhotoUrl != null
        ? NetworkImage(_profilePhotoUrl!)
        : const AssetImage('assets/images/default_avatar.jpg')) as ImageProvider;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: profileImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _secureStorage.delete(key: 'token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSignup()),
          (route) => false,
    );
  }

  Widget _imageEditButton(Future<void> Function() onTap) {
    return GestureDetector(
      onTap: _picking ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
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
                    'assets/images/back.svg',
                    color: AppColors.textPrimary(context),
                    height: 30,
                  ),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.lightBlue))
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    _buildHeaderImages(),
                    const SizedBox(height: 60),
                    Text(
                      fullName ?? 'No Name',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildDetailsSection(),
                    const SizedBox(height: 30),
                    _buildAboutMe(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImages() {
    final background = _pickedBackground != null
        ? FileImage(_pickedBackground!)
        : (_backgroundPhotoUrl != null
        ? NetworkImage(_backgroundPhotoUrl!)
        : const AssetImage('assets/images/default_background.jpg')) as ImageProvider;

    final profile = _pickedProfile != null
        ? FileImage(_pickedProfile!)
        : (_profilePhotoUrl != null
        ? NetworkImage(_profilePhotoUrl!)
        : const AssetImage('assets/images/default_avatar.jpg')) as ImageProvider;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            image: DecorationImage(image: background, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: _imageEditButton(_pickBackgroundImage),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _showProfileImageOptions,
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.surfaceColor(context),
                  backgroundImage: profile,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildProfileDetailItem(
              icon: Icons.person, title: 'Gender', value: _gender ?? 'Select', editable: true, onTap: _selectGender),
          Divider(color: AppColors.borderColor(context), thickness: 1),
          _buildProfileDetailItem(
            icon: Icons.calendar_today,
            title: 'Birthdate',
            value: _birthdate != null ? DateFormat('dd MMMM, yyyy').format(_birthdate!) : 'Select',
            editable: true,
            onTap: _selectBirthdate,
          ),
          Divider(color: AppColors.borderColor(context), thickness: 1),
        ],
      ),
    );
  }

  Widget _buildAboutMe() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('About Me', style: TextStyle(color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _editAboutMe,
            child: Text(_aboutMe ?? 'Tell us about yourself', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: AppColors.myWhite),
        label: const Text('Log Out', style: TextStyle(color: AppColors.myWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        onPressed: _logout,
      ),
    );
  }

  Future<void> _selectGender() async {
    String? selected = _gender;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(context),
        title: Text('Select Gender', style: TextStyle(color: AppColors.textPrimary(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Male', 'Female'].map((g) {
            return RadioListTile<String>(
              title: Text(g, style: TextStyle(color: AppColors.textPrimary(context))),
              value: g,
              groupValue: selected,
              activeColor: AppColors.lightBlue,
              onChanged: (val) async {
                if (val != null) {
                  setState(() => _gender = val);
                  await _updateField({'gender': val});
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _selectBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.lightBlue,
              surface: AppColors.surfaceColor(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthdate) {
      setState(() => _birthdate = picked);
      await _updateField({'birthdate': picked.toIso8601String()});
    }
  }

  Future<void> _editAboutMe() async {
    final controller = TextEditingController(text: _aboutMe);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(context),
        title: Text('About Me', style: TextStyle(color: AppColors.textPrimary(context))),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppColors.textPrimary(context)),
          decoration: InputDecoration(
            labelText: 'About Me',
            labelStyle: TextStyle(color: AppColors.textSecondary(context)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightBlue),
            ),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightBlue),
            onPressed: () async {
              setState(() => _aboutMe = controller.text);
              await _updateField({'aboutme': controller.text});
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.myWhite)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required bool editable,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightBlue, size: 24),
          const SizedBox(width: 10),
          Text('$title:', style: TextStyle(color: AppColors.textPrimary(context), fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: editable ? onTap : null,
              child: Text(value, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16)),
            ),
          ),],
      ),
    );
  }
}