import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'passenger_bookings_controller.dart';

class PassengerBookingsView extends GetView<PassengerBookingsController> {
  const PassengerBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PassengerBookingsController>()) {
      Get.put(PassengerBookingsController());
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Aurora Gradient Background ───────────────────────────────────
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildBookingsTabList('pending'),
                        _buildBookingsTabList('accepted'),
                        _buildBookingsTabList('completed'),
                        _buildBookingsTabList('rejected'),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'My Bookings',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: const Color(0xFF00BFA5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Requested'),
          Tab(text: 'Accepted'),
          Tab(text: 'Completed'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildBookingsTabList(String status) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.getBookingsStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(status);
        }

        final bookings = snapshot.data!;
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  // Navigate to Trip Details with full booking payload
                  Get.toNamed('/trip-details', arguments: {
                    ...booking,
                    'bookingId': booking['id'] ?? '',
                    '_collection': 'bookings',
                  });
                },
                child: _buildTravelSlip(booking),
              ),
            );
          },
        );
      },
    );
  }

  // ── Glassmorphic Travel Slip ───────────────────────────────────────────────
  Widget _buildTravelSlip(Map<String, dynamic> booking) {
    final String driverId = booking['driverId'] ?? '';
    final String departure = booking['departureCity'] ?? 'Departure';
    final String destination = booking['destinationCity'] ?? 'Destination';
    final int fare = (booking['totalFare'] as num?)?.toInt() ?? 0;
    final String status = booking['status'] ?? 'pending';

    return _glassContainer(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Loader Row
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(driverId).get(),
            builder: (context, userSnap) {
              final userData = userSnap.data?.data() as Map<String, dynamic>?;
              final String name = userData?['name'] ?? 'Captain';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('drivers').doc(driverId).get(),
                builder: (context, driverSnap) {
                  final driverData = driverSnap.data?.data() as Map<String, dynamic>?;
                  final String carModel = driverData?['primaryVehicle']?['model'] ?? 'Car';

                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF00BFA5),
                        child: Icon(Icons.person, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              carModel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // ── Trailing Red Glassmorphic Trash Button ──
                      if (status == 'pending' || status == 'rejected') ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(booking['id'] ?? ''),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.redAccent,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 14),

          // Route Details
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  Container(width: 1.5, height: 16, color: Colors.white24),
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departure,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Dynamic Fare display inside FittedBox
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Rs. $fare',
                      style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Total Fare',
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── quick confirmation dialog before running the deletion block ──────────
  void _showDeleteConfirmation(String bookingId) {
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
            'Delete Booking Request?',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to remove this booking request permanently?',
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
                controller.deleteBookingRequest(bookingId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            'No Bookings Found',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Trips in status "$status" appear here',
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── UI Design Helpers ──────────────────────────────────────────────────────
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
            color: Colors.white.withValues(alpha: 0.04),
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
