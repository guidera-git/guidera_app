import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/screens/home_screen.dart';
import 'package:guidera_app/screens/signup.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/header.dart';
import '../services/api_service.dart';
import 'login-signup.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';




class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _api         = ApiService();
  final _storage = FlutterSecureStorage();

  @override
  void dispose() {
    // Dispose controllers when the widget is removed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final response = await _api.post(
      '/auth/login',
      {
        'email':    _emailController.text.trim(),
        'password': _passwordController.text,
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await _storage.write(key: 'token', value: data['token']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Login failed')),
      );
    }
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
                      MaterialPageRoute(builder: (_) => const LoginSignup()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Welcome Back",
                style: TextStyle(
                  color: AppColors.myWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Log in to your account",
                style: TextStyle(
                  color: AppColors.myGray,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              // Login Form.
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field.
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.myWhite),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle:
                        const TextStyle(color: AppColors.myGray),
                        filled: true,
                        fillColor: AppColors.lightBlack,
                        prefixIcon: const Icon(Icons.email,
                            color: AppColors.myWhite),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        // Optionally, add email format validation here.
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password Field.
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.myWhite),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle:
                        const TextStyle(color: AppColors.myGray),
                        filled: true,
                        fillColor: AppColors.lightBlack,
                        prefixIcon: const Icon(Icons.lock,
                            color: AppColors.myWhite),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Forgot Password Link.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password logic.
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: AppColors.darkBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Login Button.
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: login,
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.myWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Sign up prompt.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                        color: AppColors.myGray, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) =>
                            const SignUpScreen()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}