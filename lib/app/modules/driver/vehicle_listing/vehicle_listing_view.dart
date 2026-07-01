import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vehicle_listing_controller.dart';

class VehicleListingView extends GetView<VehicleListingController> {
  const VehicleListingView({super.key});

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
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Glow orbs
          Positioned(
            top: -80,
            left: -80,
            child: _glowOrb(const Color(0xFF00BFA5), 260),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: _glowOrb(const Color(0xFF7B1FA2), 280),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Section 1: Car Photos ─────────────────────────
                        _buildSectionTitle('Car Photos', '1 – 8 photos'),
                        const SizedBox(height: 12),
                        _buildPhotoGrid(),
                        const SizedBox(height: 24),

                        // ── Section 2: Public Specs ───────────────────────
                        _buildSectionTitle('Vehicle Specs', 'Visible to passengers'),
                        const SizedBox(height: 12),
                        _buildGlassCard(child: _buildPublicSpecsForm()),
                        const SizedBox(height: 24),

                        // ── Section 3: Private Fare Engine ────────────────
                        _buildFareEngineSection(),
                        const SizedBox(height: 36),

                        // ── Submit Button ─────────────────────────────────
                        Obx(() => controller.isLoading.value
                            ? _buildUploadProgress()
                            : _buildSaveButton()),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register Vehicle',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Step 2 of 2',
                style: GoogleFonts.poppins(
                    color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Photo Grid ─────────────────────────────────────────────────────────────
  Widget _buildPhotoGrid() {
    return Obx(() {
      final images = controller.selectedImages;
      final canAdd = images.length < VehicleListingController.maxPhotos;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: images.length + (canAdd ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return _buildAddPhotoTile();
          }
          return _buildPhotoTile(images[index], index);
        },
      );
    });
  }

  Widget _buildAddPhotoTile() {
    return GestureDetector(
      onTap: controller.pickCarImages,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_photo_alternate_outlined,
                    color: Color(0xFF00BFA5), size: 32),
                const SizedBox(height: 6),
                Text('Add Photo',
                    style: GoogleFonts.poppins(
                        color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(File file, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Cover',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Public Specs Form ──────────────────────────────────────────────────────
  Widget _buildPublicSpecsForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _glassInput(
                controller: controller.brandController,
                label: 'Brand',
                icon: Icons.directions_car_outlined,
                hint: 'Toyota',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _glassInput(
                controller: controller.makeController,
                label: 'Make',
                icon: Icons.label_outline,
                hint: 'Corolla',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _glassInput(
                controller: controller.modelController,
                label: 'Model Year',
                icon: Icons.calendar_today_outlined,
                hint: '2022',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _glassInput(
                controller: controller.variantController,
                label: 'Variant',
                icon: Icons.tune_outlined,
                hint: 'GLi',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _glassInput(
          controller: controller.seatsController,
          label: 'Total Seats',
          icon: Icons.event_seat_outlined,
          hint: '4',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        // AC Toggle
        Obx(() => _buildAcToggle()),
      ],
    );
  }

  Widget _buildAcToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: controller.isAc.value
            ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: controller.isAc.value
              ? const Color(0xFF00BFA5).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.ac_unit,
            color: controller.isAc.value
                ? const Color(0xFF00BFA5)
                : Colors.white38,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Air Conditioning',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  controller.isAc.value ? 'AC Equipped' : 'Non-AC',
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: controller.isAc.value,
            onChanged: (val) => controller.isAc.value = val,
            activeThumbColor: const Color(0xFF00BFA5),
          ),
        ],
      ),
    );
  }

  // ── Fare Engine Section ─────────────────────────────────────────────────────
  Widget _buildFareEngineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFF311B92)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calculate_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRIVATE FARE ENGINE',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Only you can see this — used to auto-calculate fares',
                    style: GoogleFonts.poppins(
                        color: Colors.white38, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7B1FA2).withValues(alpha: 0.15),
                    const Color(0xFF311B92).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF7B1FA2).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _fareInput(
                    controller: controller.mileageController,
                    label: 'Mileage (km/litre)',
                    icon: Icons.speed_outlined,
                    hint: '12',
                    suffix: 'km/L',
                  ),
                  const SizedBox(height: 12),
                  _fareInput(
                    controller: controller.fuelPriceController,
                    label: 'Fuel Price (PKR/litre)',
                    icon: Icons.local_gas_station_outlined,
                    hint: '280',
                    suffix: 'PKR',
                  ),
                  const SizedBox(height: 12),
                  _fareInput(
                    controller: controller.profitMarginController,
                    label: 'Profit Margin (%)',
                    icon: Icons.trending_up_outlined,
                    hint: '15',
                    suffix: '%',
                  ),
                  const SizedBox(height: 14),
                  _buildFarePreview(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFarePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fare = (Distance ÷ Mileage) × Fuel Price × (1 + Margin%)',
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ── Upload Progress ─────────────────────────────────────────────────────────
  Widget _buildUploadProgress() {
    return Obx(() => Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: controller.uploadProgress.value,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF00BFA5)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              controller.uploadStatus.value,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
            ),
          ],
        ));
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.saveVehicle,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFF00BFA5).withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Register Vehicle & Go Live',
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
  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassInput({
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
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fareInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? suffix,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF7B1FA2).withValues(alpha: 0.2)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.poppins(
                  color: const Color(0xFFCE93D8), fontSize: 13),
              hintStyle:
                  GoogleFonts.poppins(color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(icon,
                  color: const Color(0xFFCE93D8), size: 18),
              suffixText: suffix,
              suffixStyle: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
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
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
