import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'driver_trips_controller.dart';

class DriverTripsView extends GetView<DriverTripsController> {
  const DriverTripsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DriverTripsController>()) {
      Get.put(DriverTripsController());
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Aurora Gradient Background ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF003D45), // Deep Ocean Teal
                    Color(0xFF0A1628), // Dark Blue
                    Color(0xFF0C101A), // Midnight Dark
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Glowing Orbs
            Positioned(
              top: -80,
              left: -60,
              child: _glowOrb(const Color(0xFF00BFA5), 220),
            ),
            Positioned(
              bottom: 60,
              right: -80,
              child: _glowOrb(const Color(0xFF1565C0), 200),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildTabBar(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Obx(() => _buildTripList(controller.activeTodayTrips, "No active trips today.", isActiveTab: true)),
                        Obx(() => _buildTripList(controller.upcomingTrips, "No upcoming trips scheduled.")),
                        Obx(() => _buildTripList(controller.completedTrips, "No completed trips yet.")),
                      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: _glassIcon(Icons.arrow_back_ios_new),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Active Trips',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your booked passenger rides',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: const Color(0xFF00BFA5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Active / Live'),
          Tab(text: 'Upcoming'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildTripList(List<Map<String, dynamic>> trips, String emptyText, {bool isActiveTab = false}) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)));
    }
    if (trips.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car_outlined, color: Colors.white24, size: 64),
              const SizedBox(height: 16),
              Text(
                emptyText,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: trips.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final booking = trips[i];
        return GestureDetector(
          onTap: () {
            Get.toNamed('/trip-details', arguments: booking);
          },
          child: _buildTripCard(booking, isActiveTab: isActiveTab),
        );
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> booking, {bool isActiveTab = false}) {
    final String passengerName = booking['passengerName'] ?? 'Passenger';
    final String departure = booking['departureCity'] ?? booking['fromCity'] ?? 'N/A';
    final String destination = booking['destinationCity'] ?? booking['toCity'] ?? 'N/A';
    final int fare = (booking['totalFare'] ?? booking['fare'] as num?)?.toInt() ?? 0;
    final String status = booking['status'] ?? 'confirmed';
    final bool tokenPaid = booking['tokenPaid'] ?? false;
    final rawDate = booking['journeyDate'] ?? booking['travelDate'] ?? booking['tripDate'];
    final String bookingId = booking['id'] ?? '';

    return _glassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Passenger Details
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF00BFA5).withOpacity(0.15),
                child: Text(
                  passengerName.isNotEmpty ? passengerName[0].toUpperCase() : 'P',
                  style: GoogleFonts.poppins(color: const Color(0xFF00BFA5), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            passengerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.formatDate(rawDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(status),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 14),

          // Route Details
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.greenAccent, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$departure  ➔  $destination',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Rs. $fare',
                  style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Token Verification Info Badge inside card
          Row(
            children: [
              Expanded(
                child: tokenPaid
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BFA5).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.2)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user, color: Color(0xFF00BFA5), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                "Advance Paid & Verified: Rs. ${booking['tokenAmount'] ?? 0}",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amberAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                "Awaiting Passenger Advance Token",
                                style: GoogleFonts.poppins(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),

          if (isActiveTab && (status == 'confirmed' || status == 'ongoing')) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'confirmed' 
                          ? const Color(0xFF00BFA5).withOpacity(0.8)
                          : Colors.redAccent.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (status == 'confirmed') {
                        controller.startActiveTrip(bookingId);
                      } else if (status == 'ongoing') {
                        controller.completeActiveTrip(bookingId);
                      }
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        status == 'confirmed' 
                            ? "▶️ Start Trip / سفر شروع کریں" 
                            : "🛑 End / Complete Trip / سفر مکمل کریں",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.cyanAccent;
    if (status == 'ongoing') {
      color = const Color(0xFF00BFA5);
    } else if (status == 'completed') {
      color = Colors.greenAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }

  Widget _glassIcon(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
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
          colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  Widget _glassContainer({
    required Widget child,
    required BorderRadius borderRadius,
    required EdgeInsetsGeometry padding,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // transparent white10
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
