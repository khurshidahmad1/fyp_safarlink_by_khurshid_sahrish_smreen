import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'driver_kyc_controller.dart';

class DriverKycView extends GetView<DriverKycController> {
  const DriverKycView({super.key});

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
                  Color(0xFF003D45), // Deep Teal
                  Color(0xFF0A1628), // Midnight Blue
                  Color(0xFF0C101A), // Near Black
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Ambient glow orbs
          Positioned(
            top: -100,
            right: -80,
            child: _glowOrb(const Color(0xFF00BFA5), 280),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _glowOrb(const Color(0xFF1A237E), 300),
          ),

          // ── Main Content ────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 28),

                  // Profile Photo Upload
                  _buildSectionTitle('Profile Photo'),
                  const SizedBox(height: 12),
                  _buildProfilePhotoUpload(),
                  const SizedBox(height: 24),

                  // Personal Info
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 12),
                  _buildGlassInput(
                    controller: controller.nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _buildGlassInput(
                    controller: controller.phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildGlassInput(
                    controller: controller.addaCityController,
                    label: 'Adda City (e.g. Okara)',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildGlassInput(
                    controller: controller.cnicController,
                    label: 'CNIC Number (13 digits)',
                    icon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                  ),
                  const SizedBox(height: 28),

                  // Document Upload Section
                  _buildSectionTitle('Identity Documents'),
                  const SizedBox(height: 4),
                  Text(
                    'These are kept private and never shared with passengers',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CNIC Upload
                  _buildDocUploadBox(
                    label: 'National ID (CNIC)',
                    subtitle: 'Front side — tap to capture',
                    icon: Icons.credit_card,
                    color: const Color(0xFF00BFA5),
                    fileObs: controller.cnicPhoto,
                    onTap: controller.pickCnicPhoto,
                  ),
                  const SizedBox(height: 16),

                  // Driving License Toggle + Upload
                  _buildLicenseSection(),
                  const SizedBox(height: 36),

                  // Submit Button
                  Obx(() => controller.isLoading.value
                      ? _buildLoadingState()
                      : _buildSubmitButton()),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: _buildGlassIcon(Icons.arrow_back_ios_new),
        ),
        const SizedBox(height: 20),
        Text(
          'Driver Verification',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete your KYC to start earning with Safarlink',
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        // Progress indicator
        Row(
          children: [
            _buildProgressDot(true, 'KYC'),
            _buildProgressLine(false),
            _buildProgressDot(false, 'Vehicle'),
            _buildProgressLine(false),
            _buildProgressDot(false, 'Active'),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressDot(bool active, String label) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? const Color(0xFF00BFA5)
                : Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: active
                  ? const Color(0xFF00BFA5)
                  : Colors.white24,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.5),
                      blurRadius: 12,
                    )
                  ]
                : null,
          ),
          child: Icon(
            active ? Icons.check : Icons.circle_outlined,
            size: 14,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: active ? Colors.white70 : Colors.white30,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active
            ? const Color(0xFF00BFA5)
            : Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  // ── Profile Photo ─────────────────────────────────────────────────────────
  Widget _buildProfilePhotoUpload() {
    return Center(
      child: Obx(() {
        final file = controller.profilePhoto.value;
        return GestureDetector(
          onTap: controller.pickProfilePhoto,
          child: Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF1A237E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: file != null
                        ? Image.file(file, fit: BoxFit.cover)
                        : Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.white70,
                              size: 36,
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00BFA5),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Glass Input ────────────────────────────────────────────────────────────
  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: Colors.white54),
              prefixIcon: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterStyle: const TextStyle(color: Colors.white38),
            ),
          ),
        ),
      ),
    );
  }

  // ── Document Upload Box ────────────────────────────────────────────────────
  Widget _buildDocUploadBox({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Rx<File?> fileObs,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final file = fileObs.value;
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: file != null
                  ? color
                  : Colors.white.withValues(alpha: 0.2),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            color: file != null
                ? color.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.04),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: file != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(file, fit: BoxFit.cover),
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.greenAccent, size: 32),
                                const SizedBox(height: 6),
                                Text('Tap to replace',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: color, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  // ── License Section ─────────────────────────────────────────────────────────
  Widget _buildLicenseSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Driving License',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Adds credibility to your profile',
                              style: GoogleFonts.poppins(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: controller.hasDrivingLicense.value,
                        onChanged: (val) =>
                            controller.hasDrivingLicense.value = val,
                        activeThumbColor: const Color(0xFF00BFA5),
                        thumbColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.white,
                        ),
                      ),
                    ],
                  )),
              Obx(() {
                if (!controller.hasDrivingLicense.value) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildDocUploadBox(
                    label: 'Driving License Photo',
                    subtitle: 'Front side — tap to capture',
                    icon: Icons.drive_eta_outlined,
                    color: const Color(0xFFFFB4A2),
                    fileObs: controller.licensePhoto,
                    onTap: controller.pickLicensePhoto,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Loading & Submit ────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Obx(() => Column(
          children: [
            const LinearProgressIndicator(
              color: Color(0xFF00BFA5),
              backgroundColor: Colors.white12,
            ),
            const SizedBox(height: 12),
            Text(
              controller.uploadStatus.value,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.submitKyc,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFF00BFA5).withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Submit & Continue to Vehicle',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.poppins(
        color: Colors.white60,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildGlassIcon(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
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
