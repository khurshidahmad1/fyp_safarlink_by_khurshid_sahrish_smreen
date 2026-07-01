import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../email_auth_controller.dart';

class EmailAuthView extends GetView<EmailAuthController> {
  const EmailAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF003D45), // Deep Ocean Teal
                  Color(0xFF0C101A), // Dark Midnight Blue
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Obx(
                          () => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.isLoginMode.value ? "Email Login" : "Email Signup",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.isLoginMode.value
                                    ? "Welcome back! Enter your credentials to log in."
                                    : "Create an account to start your journey.",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Email Input Field
                              TextField(
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email, color: Colors.white70),
                                  hintText: "example@email.com",
                                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.05),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFFE6B24)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Password Input Field
                              TextField(
                                controller: controller.passwordController,
                                obscureText: true,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                                  hintText: "Password",
                                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.05),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFFE6B24)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Main Button
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.authenticate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFE6B24),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          controller.isLoginMode.value ? "Login" : "Sign Up",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Toggle Mode Button
                              Center(
                                child: TextButton(
                                  onPressed: controller.toggleMode,
                                  child: Text(
                                    controller.isLoginMode.value
                                        ? "Don't have an account? Sign up"
                                        : "Already have an account? Log in",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
