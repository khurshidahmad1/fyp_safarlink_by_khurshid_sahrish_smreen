import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'car_registration_controller.dart';

class CarRegistrationView extends GetView<CarRegistrationController> {
  const CarRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Text(
                    "Car Registration",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Setup your vehicle & private fare configuration",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: Car Details
                  _buildGlassSection(
                    title: "CAR DETAILS",
                    icon: Icons.directions_car_outlined,
                    children: [
                      _buildTextField(
                        controller: controller.brandController,
                        label: "Brand (e.g. Toyota, Honda)",
                        icon: Icons.branding_watermark_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.modelController,
                        label: "Model / Year (e.g. Corolla 2022)",
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.seatsController,
                        label: "Available Seats",
                        icon: Icons.event_seat_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Obx(() => SwitchListTile(
                            title: Text(
                              "Air Conditioning (AC)",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              "Toggle AC availability for fares",
                              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                            ),
                            value: controller.isAc.value,
                            activeThumbColor: Colors.cyanAccent,
                            activeTrackColor: Colors.cyan.withValues(alpha: 0.3),
                            inactiveThumbColor: Colors.white60,
                            inactiveTrackColor: Colors.white10,
                            onChanged: (val) => controller.isAc.value = val,
                            contentPadding: EdgeInsets.zero,
                          )),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Base Location
                  _buildGlassSection(
                    title: "BASE LOCATION",
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildTextField(
                        controller: controller.addaController,
                        label: "Adda City (e.g. Okara)",
                        icon: Icons.apartment_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Fare Engine Setup (Visually Distinct)
                  _buildFareEngineSection(),
                  const SizedBox(height: 32),

                  // Save Button
                  Obx(() => SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.submitRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.teal.withValues(alpha: 0.5),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  "Save Registration",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return _buildGlassContainer(
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFareEngineSection() {
    // Visually distinct container with extra border neon color
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.greenAccent.withValues(alpha: 0.3), // distinct green hue border
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.calculate_outlined, color: Colors.greenAccent, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "PRIVATE FARE ENGINE SETUP",
                              style: GoogleFonts.poppins(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.lock_outline, color: Colors.greenAccent, size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "These settings are private and used to calculate dynamic fares shown to passengers.",
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: controller.mileageController,
                  label: "Fuel Mileage (KM/Litre)",
                  icon: Icons.speed_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.fuelPriceController,
                  label: "Current Fuel Price (Rs./Litre)",
                  icon: Icons.local_gas_station_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.profitMarginController,
                  label: "Profit Margin Markup (%)",
                  icon: Icons.trending_up_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
