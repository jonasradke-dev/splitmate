import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitmate/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// **Checks if the user is already logged in and redirects to Home**
  Future<void> _checkLoginStatus() async {
    print("🔄 Checking if user is already logged in...");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token != null) {
        print("✅ User is already logged in, redirecting to Home...");
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        print("❌ No auth token found, staying on Login Page.");
      }
    } catch (e) {
      print("❌ Error checking login status: $e");
    }
  }

  /// **Handles login process**
  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    print("🔄 Attempting to login with email: ${emailController.text}");

    try {
      String? error = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (error == null) {
        print("✅ Login successful! Redirecting to Home...");
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        print("❌ Login failed: $error");
        setState(() {
          errorMessage = error;
        });
      }
    } catch (e) {
      print("❌ Unexpected error during login: $e");
      setState(() {
        isLoading = false;
        errorMessage = "An unexpected error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Login to SplitMate",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.purpleAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.purpleAccent,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.purpleAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.purpleAccent,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator(color: Colors.purpleAccent)
                  : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 50,
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  print("🔄 Navigating to Register Page...");
                  Navigator.pushReplacementNamed(context, "/register");
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.purpleAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
