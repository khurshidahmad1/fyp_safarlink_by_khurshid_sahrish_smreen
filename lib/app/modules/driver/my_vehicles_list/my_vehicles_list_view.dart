import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/vehicle_model.dart';
import 'my_vehicles_list_controller.dart';

class MyVehiclesListView extends GetView<MyVehiclesListController> {
  const MyVehiclesListView({super.key});

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
                  child: Obx(() {
                    if (controller.isLoading.value && controller.vehicles.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
                      );
                    }

                    if (controller.vehicles.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: controller.vehicles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final vehicle = controller.vehicles[index];
                        return _buildVehicleCard(context, vehicle);
                      },
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
            'My Fleet Listings',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'No Vehicles Listed',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t listed any vehicles yet.',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Vehicle Card ───────────────────────────────────────────────────────────
  Widget _buildVehicleCard(BuildContext context, VehicleModel vehicle) {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with name and delete button
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${vehicle.brand} ${vehicle.make}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.deleteVehicle(vehicle.vehicleId),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Model: ${vehicle.model} • Variant: ${vehicle.variant}',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Horizontal thumbnail track of its photos
            if (vehicle.carPhotos.isNotEmpty) ...[
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: vehicle.carPhotos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        vehicle.carPhotos[index],
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 60,
                          color: Colors.white10,
                          child: const Icon(Icons.broken_image, color: Colors.white38, size: 20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Specs Row (Seats & AC Status)
            Row(
              children: [
                _buildSpecBadge(Icons.event_seat_outlined, '${vehicle.totalSeats} Seats'),
                const SizedBox(width: 8),
                _buildSpecBadge(Icons.ac_unit_outlined, vehicle.isAc ? 'AC Equipped' : 'Non-AC'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),

            // Edit Specs button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _showEditVehicleSheet(context, vehicle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: const Color(0xFF00BFA5).withValues(alpha: 0.3)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Vehicle Details',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Show Edit Vehicle Full Sheet ───────────────────────────────────────────
  void _showEditVehicleSheet(BuildContext context, VehicleModel vehicle) {
    final brandCtrl = TextEditingController(text: vehicle.brand);
    final makeCtrl = TextEditingController(text: vehicle.make);
    final modelCtrl = TextEditingController(text: vehicle.model);
    final variantCtrl = TextEditingController(text: vehicle.variant);
    final seatsCtrl = TextEditingController(text: vehicle.totalSeats.toString());
    
    // Fare Engine Metrics
    final mileageCtrl = TextEditingController(text: vehicle.mileageKmPerLitre.toString());
    final fuelPriceCtrl = TextEditingController(text: vehicle.fuelPrice.toString());
    final profitMarginCtrl = TextEditingController(text: vehicle.profitMarginPercentage.toString());

    final RxBool localIsAc = vehicle.isAc.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628).withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
              ),
              child: Column(
                children: [
                  // Handle Bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sheet Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Vehicle Specs',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white60),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12),

                  // Scrollable form fields
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPECIFICATIONS',
                            style: GoogleFonts.poppins(
                              color: Colors.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSheetInput(
                                  controller: brandCtrl,
                                  label: 'Brand',
                                  hint: 'Toyota',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSheetInput(
                                  controller: makeCtrl,
                                  label: 'Make',
                                  hint: 'Corolla',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSheetInput(
                                  controller: modelCtrl,
                                  label: 'Model Year',
                                  hint: '2022',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSheetInput(
                                  controller: variantCtrl,
                                  label: 'Variant',
                                  hint: 'GLi',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildSheetInput(
                            controller: seatsCtrl,
                            label: 'Total Available Seats',
                            hint: '4',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // AC Switch Tile
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.ac_unit_outlined, color: Colors.white54, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Air Conditioning',
                                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            localIsAc.value ? 'AC Equipped' : 'Non-AC',
                                            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: localIsAc.value,
                                      onChanged: (val) => localIsAc.value = val,
                                      activeThumbColor: const Color(0xFF00BFA5),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 28),

                          Text(
                            'PRIVATE FARE METRICS',
                            style: GoogleFonts.poppins(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          _buildSheetInput(
                            controller: mileageCtrl,
                            label: 'Fuel Mileage (km/L)',
                            hint: '12',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSheetInput(
                                  controller: fuelPriceCtrl,
                                  label: 'Fuel Price (Rs./L)',
                                  hint: '280',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSheetInput(
                                  controller: profitMarginCtrl,
                                  label: 'Profit Margin (%)',
                                  hint: '15',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                final double? mileage = double.tryParse(mileageCtrl.text);
                                final double? fuelPrice = double.tryParse(fuelPriceCtrl.text);
                                final double? margin = double.tryParse(profitMarginCtrl.text);
                                final int? seats = int.tryParse(seatsCtrl.text);

                                if (brandCtrl.text.trim().isEmpty ||
                                    makeCtrl.text.trim().isEmpty ||
                                    modelCtrl.text.trim().isEmpty ||
                                    seats == null ||
                                    mileage == null ||
                                    fuelPrice == null ||
                                    margin == null) {
                                  Get.snackbar(
                                    'Validation Error',
                                    'Please check that all fields are non-empty and numbers parse correctly.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                final updated = vehicle.copyWith(
                                  brand: brandCtrl.text.trim(),
                                  make: makeCtrl.text.trim(),
                                  model: modelCtrl.text.trim(),
                                  variant: variantCtrl.text.trim(),
                                  totalSeats: seats,
                                  isAc: localIsAc.value,
                                  mileageKmPerLitre: mileage,
                                  fuelPrice: fuelPrice,
                                  profitMarginPercentage: margin,
                                );

                                Get.back(); // close sheet
                                controller.updateVehicleDetails(vehicle.vehicleId, updated);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BFA5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Save Vehicle Config',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildSheetInput({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
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
