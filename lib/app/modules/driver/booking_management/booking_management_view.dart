import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_management_controller.dart';

class BookingManagementView extends GetView<BookingManagementController> {
  const BookingManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BookingManagementController>()) {
      Get.put(BookingManagementController());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Custom Glassmorphic Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildGlassContainer(
                      borderRadius: BorderRadius.circular(16),
                      child: TabBar(
                        indicatorColor: Colors.cyanAccent,
                        labelColor: Colors.cyanAccent,
                        unselectedLabelColor: Colors.white60,
                        dividerColor: Colors.transparent,
                        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                        tabs: const [
                          Tab(text: "Upcoming"),
                          Tab(text: "Past / History"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Views
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TabBarView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTripList(controller.upcomingTrips, isUpcoming: true),
                          _buildTripList(controller.pastTrips, isUpcoming: false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                "Trip Bookings",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Track all passenger bookings & history",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(RxList<BookingTrip> trips, {required bool isUpcoming}) {
    return Obx(() {
      if (trips.isEmpty) {
        return Center(
          child: Text(
            "No bookings found",
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
          ),
        );
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: trips.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final trip = trips[index];
          return GestureDetector(
            onTap: () => Get.toNamed(
              '/trip-details',
              arguments: {'bookingId': trip.id},
            ),
            child: _buildGlassContainer(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white12,
                          child: Text(
                            trip.passengerName.isNotEmpty ? trip.passengerName[0].toUpperCase() : '?',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            trip.passengerName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          trip.fare,
                          style: GoogleFonts.poppins(
                            color: Colors.cyanAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 8),
                    
                    // Route
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFFFB4A2), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.route,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Status
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Status: ",
                          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                        ),
                        Text(
                          trip.tokenStatus,
                          style: GoogleFonts.poppins(
                            color: trip.tokenStatus.contains('CONFIRMED') || trip.tokenStatus.contains('PAID')
                                ? Colors.greenAccent 
                                : (trip.tokenStatus.contains('COMPLETED') ? Colors.cyanAccent : Colors.redAccent),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    if (isUpcoming) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Get.toNamed(
                                '/trip-details',
                                arguments: {'bookingId': trip.id},
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Start / View Trip",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
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
