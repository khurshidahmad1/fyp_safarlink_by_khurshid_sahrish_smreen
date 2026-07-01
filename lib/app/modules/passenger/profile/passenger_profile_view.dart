import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'passenger_profile_controller.dart';

class PassengerProfileView extends GetView<PassengerProfileController> {
  const PassengerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazy put controller if it's not already in memory (makes view highly re-usable as subtab and page)
    if (!Get.isRegistered<PassengerProfileController>()) {
      Get.put(PassengerProfileController());
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Aurora Gradient Background ─────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF003D45),
                  Color(0xFF0A1628),
                  Color(0xFF0C101A),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // Glow Orbs
          Positioned(
            top: -120,
            right: -80,
            child: _glowOrb(const Color(0xFF00BFA5), 300),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _glowOrb(const Color(0xFF1565C0), 260),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildProfilePhotoSection(),
                          const SizedBox(height: 24),
                          _buildEditableCardSection(),
                          const SizedBox(height: 24),
                          _buildLogoutCard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildFixedBottomSaveButton(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: _glassIconButton(Icons.arrow_back_ios_new),
        ),
        const SizedBox(width: 16),
        Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00BFA5), width: 2),
            ),
            child: Obx(() => CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  backgroundImage: controller.profilePhotoUrl.value.isNotEmpty
                      ? NetworkImage(controller.profilePhotoUrl.value)
                      : null,
                  child: controller.profilePhotoUrl.value.isEmpty
                      ? const Icon(Icons.person, size: 48, color: Colors.white60)
                      : null,
                )),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF00BFA5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCardSection() {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.manage_accounts, color: Color(0xFF00BFA5), size: 18),
              const SizedBox(width: 8),
              Text(
                'PERSONAL DETAILS',
                style: GoogleFonts.poppins(
                  color: Colors.cyanAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Full Name
          Text(
            'Full Name',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: controller.nameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // Base City
          Text(
            'Base City',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: controller.cityController,
            hint: 'e.g. Okara',
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 16),

          // Phone Number
          Text(
            'Phone Number',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: controller.phoneController,
            hint: 'e.g. +92 300 1234567',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Complete Postal Address
          Text(
            'Complete Postal Address',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: controller.addressController,
            hint: 'Enter complete postal address',
            icon: Icons.home_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFixedBottomSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.2)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              elevation: 0,
            ),
            child: controller.isSaving.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Save Profile',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  // ── UI Design Helpers ──────────────────────────────────────────────────────
  Widget _buildLogoutCard() {
    return GestureDetector(
      onTap: _showLogoutConfirmation,
      child: _glassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderColor: Colors.redAccent.withValues(alpha: 0.35),
        child: Row(
          children: [
            const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Logout from Safarlink',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0C101A).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          title: Text(
            'Logout Confirmation',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to end your session and logout?',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.logoutUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UI Design Helpers ──────────────────────────────────────────────────────
  Widget _glassContainer({
    required Widget child,
    required BorderRadius borderRadius,
    required EdgeInsetsGeometry padding,
    Color? color,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.04),
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF00BFA5), size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
        ),
      ),
    );
  }

  Widget _glassIconButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _glowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
