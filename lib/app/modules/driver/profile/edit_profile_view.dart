import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Glow orbs
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
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
                      );
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Profile Photo Section
                          _buildProfilePhotoSection(),
                          const SizedBox(height: 36),

                          // Form Card with TextFields
                          _buildFormCard(),
                          const SizedBox(height: 36),

                          // Save Button
                          _buildSaveButton(),
                          const SizedBox(height: 20),

                          // Account Deletion Danger Zone
                          _buildDangerZone(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: _glassIconButton(Icons.arrow_back_ios_new),
          ),
          const SizedBox(width: 16),
          Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Photo Section ──────────────────────────────────────────────────
  Widget _buildProfilePhotoSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glassContainer(
          borderRadius: BorderRadius.circular(60),
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: const Color(0xFF00BFA5),
            backgroundImage: controller.profilePhotoUrl.value.isNotEmpty
                ? NetworkImage(controller.profilePhotoUrl.value)
                : null,
            child: controller.profilePhotoUrl.value.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 52)
                : null,
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: controller.isUploading.value ? null : controller.pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00BFA5),
              ),
              child: controller.isUploading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ── Form Card ──────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'PERSONAL DETAILS',
                  style: GoogleFonts.poppins(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: controller.nameController,
            label: 'Full Name',
            icon: Icons.person,
            hint: 'Captain Name',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            hint: '+923001234567',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.addaCityController,
            label: 'Base Adda City',
            icon: Icons.location_city,
            hint: 'Okara',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.emailController,
            label: 'Email Address',
            icon: Icons.email,
            hint: 'driver@safarlink.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.cnicController,
            label: 'CNIC Number',
            icon: Icons.badge,
            hint: '35202-1234567-1',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          
          // Driving License Status switch tile
          Obx(() => Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Driving License Status',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    controller.hasDrivingLicense.value ? 'License Verified / Available' : 'No License Listed',
                    style: GoogleFonts.poppins(
                      color: controller.hasDrivingLicense.value ? Colors.greenAccent : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  value: controller.hasDrivingLicense.value,
                  activeThumbColor: const Color(0xFF00BFA5),
                  activeTrackColor: const Color(0xFF00BFA5).withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.white38,
                  inactiveTrackColor: Colors.white10,
                  onChanged: (val) => controller.hasDrivingLicense.value = val,
                ),
              )),
        ],
      ),
    );
  }

  // ── Save Changes Button ───────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFF00BFA5).withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 22),
            const SizedBox(width: 10),
            Text(
              'Save Changes',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ── Danger Zone ────────────────────────────────────────────────────────────
  Widget _buildDangerZone(BuildContext context) {
    return InkWell(
      onTap: () => _showDeleteAccountDialog(context),
      borderRadius: BorderRadius.circular(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_forever, color: Colors.redAccent, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Delete Account',
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Double Authenticated Deletion Dialog ────────────────────────────────────
  void _showDeleteAccountDialog(BuildContext context) {
    controller.passwordController.clear();
    Get.defaultDialog(
      title: '⚠️ Verify Password',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            const Text(
              'Enter your account password to verify identity for permanent account deletion. This action is irreversible.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Delete Permanently',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        final password = controller.passwordController.text.trim();
        Get.back();
        controller.deleteAccount(password);
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFF00BFA5), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassContainer({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassIconButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
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
