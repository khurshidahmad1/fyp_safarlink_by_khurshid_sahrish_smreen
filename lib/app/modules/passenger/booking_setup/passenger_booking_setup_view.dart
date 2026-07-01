import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'passenger_booking_setup_controller.dart';

class PassengerBookingSetupView extends GetView<PassengerBookingSetupController> {
  const PassengerBookingSetupView({super.key});

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildAppBar(),
                  const SizedBox(height: 24),
                  _buildDriverHeaderCard(),
                  const SizedBox(height: 24),
                  _buildBookingFormCard(context),
                  const SizedBox(height: 28),
                  
                  // Passenger Confidential Pricing Engine Panel
                  Obx(() {
                    if (controller.isCalculatingFare.value) {
                      return _buildShimmerPlaceholder();
                    }
                    if (controller.totalCalculatedFare.value > 0) {
                      return _buildConfidentialFareCard();
                    }
                    return _buildPlaceholderInstruction();
                  }),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Glassmorphic AppBar ───────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: _glassIconButton(Icons.arrow_back_ios_new),
        ),
        const SizedBox(width: 16),
        Text(
          'Booking Setup',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Driver Info Summary ────────────────────────────────────────────────────
  Widget _buildDriverHeaderCard() {
    return Obx(() => _glassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF00BFA5),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              
              // Wrapped inside Expanded to prevent overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.driverName.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.carModelText.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.cyanAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  // ── Booking details form: Departure, Destination, Travel Date Picker ───────
  Widget _buildBookingFormCard(BuildContext context) {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route, color: Color(0xFF00BFA5), size: 18),
              const SizedBox(width: 8),
              Text(
                'BOOKING DETAILS',
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

          // Departure City/Adda
          Text(
            'Departure City/Adda',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: controller.departureController,
            hint: 'e.g. Lahore Adda',
            icon: Icons.my_location,
          ),
          const SizedBox(height: 16),

          // Destination City
          Text(
            'Destination City',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _buildInputBox(
            controller: controller.destinationController,
            hint: 'e.g. Islamabad',
            icon: Icons.flag,
          ),
          const SizedBox(height: 16),

          // Travel Date Picker
          Text(
            'Travel Schedule Date',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _buildDatePickerField(context),
          const SizedBox(height: 16),

          // Trip Type Selection
          Text(
            'Trip Type Selection',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.toggleTripType(false),
                  child: _glassContainer(
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    color: !controller.isRoundTrip.value 
                        ? const Color(0xFF00BFA5).withValues(alpha: 0.15) 
                        : Colors.white.withValues(alpha: 0.02),
                    borderColor: !controller.isRoundTrip.value 
                        ? const Color(0xFF00BFA5).withValues(alpha: 0.3) 
                        : Colors.white.withValues(alpha: 0.08),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: !controller.isRoundTrip.value ? const Color(0xFF00BFA5) : Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'One-Way / Sirf Jaana',
                            style: GoogleFonts.poppins(
                              color: !controller.isRoundTrip.value ? Colors.white : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.toggleTripType(true),
                  child: _glassContainer(
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    color: controller.isRoundTrip.value 
                        ? const Color(0xFF00BFA5).withValues(alpha: 0.15) 
                        : Colors.white.withValues(alpha: 0.02),
                    borderColor: controller.isRoundTrip.value 
                        ? const Color(0xFF00BFA5).withValues(alpha: 0.3) 
                        : Colors.white.withValues(alpha: 0.08),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_calls,
                          color: controller.isRoundTrip.value ? const Color(0xFF00BFA5) : Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Round-Trip / Aana-Jaana',
                            style: GoogleFonts.poppins(
                              color: controller.isRoundTrip.value ? Colors.white : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
          
          const SizedBox(height: 20),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => controller.calculateRouteAndFare(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF00BFA5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF00BFA5), width: 1.2),
                ),
                elevation: 0,
              ),
              child: Text(
                'Calculate Fare',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Picker Selector Widget ─────────────────────────────────────────────
  Widget _buildDatePickerField(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF00BFA5), size: 18),
            const SizedBox(width: 12),
            Obx(() {
              final date = controller.selectedDate.value;
              return Text(
                "${date.day}/${date.month}/${date.year}",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              );
            }),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  // ── ITEM 3: Confidential Fare Display Card ─────────────────────────────────
  Widget _buildConfidentialFareCard() {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Route Distance: ${controller.routeDistanceKm.value.toStringAsFixed(1)} KM',
                  style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // CRITICAL: Wrapped in FittedBox to guarantee 0% overflow clipping
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Total Fare: Rs. ${controller.totalCalculatedFare.value}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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

  Widget _buildPlaceholderInstruction() {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.pin_drop, color: Colors.white38, size: 28),
            const SizedBox(height: 12),
            Text(
              'Dynamic Pricing Awaiting Locations',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Input departure adda and target destination to calculate inter-city fare.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white30,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.15),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 54,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: controller.isSubmitting.value ? null : controller.sendBookingRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
                ),
                elevation: 0,
              ),
              child: controller.isSubmitting.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Send Ride Request',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ));
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
