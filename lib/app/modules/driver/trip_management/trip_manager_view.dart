import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trip_manager_controller.dart';
import '../../shared/widgets/cancellation_bottom_sheet.dart';

class TripManagerView extends GetView<TripManagerController> {
  const TripManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF003D45), Color(0xFF0A1628), Color(0xFF0C101A)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(top: -80, left: -60, child: _glowOrb(const Color(0xFFFFB4A2), 220)),
          Positioned(bottom: 60, right: -80, child: _glowOrb(const Color(0xFF00BFA5), 200)),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabs(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)));
                    }
                    return controller.selectedTab.value == 0
                        ? _buildTripList(controller.activeTrips, isActive: true)
                        : _buildTripList(controller.pastTrips, isActive: false);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: _glassIcon(Icons.arrow_back_ios_new),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trip Management', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Manage your rides', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Obx(() => Row(
            children: [
              _tabButton('Active', 0),
              const SizedBox(width: 10),
              _tabButton('History', 1),
            ],
          )),
    );
  }

  Widget _tabButton(String label, int index) {
    final active = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectedTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00BFA5) : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF00BFA5) : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: active ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTripList(List<TripModel> trips, {required bool isActive}) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.directions_car_outlined : Icons.history_outlined,
                color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(isActive ? 'No Active Trips' : 'No Trip History',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              isActive ? 'Accept requests to see trips here' : 'Completed trips will show here',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: trips.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 14),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () {
          final trip = trips[i];
          Get.toNamed('/trip-details', arguments: trip.rawData);
        },
        child: _buildTripCard(trips[i], isActive: isActive),
      ),
    );
  }

  Widget _buildTripCard(TripModel trip, {required bool isActive}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
                            child: Text(
                              trip.passengerName[0].toUpperCase(),
                              style: GoogleFonts.poppins(color: const Color(0xFFFFB4A2), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trip.passengerName,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              Text('${trip.seats} seat(s) • ${controller.formatDate(trip.tripDate)}',
                                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(trip.status),
                  ],
                ),

                const SizedBox(height: 14),

                // Route
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 6),
                    Text('${trip.fromCity}  ➔  ${trip.toCity}',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                    const Spacer(),
                    Text('Rs. ${trip.fare.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),

                if (isActive) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _callPassenger(trip.passengerPhone),
                          icon: const Icon(Icons.phone_outlined, size: 16),
                          label: Text('Call', style: GoogleFonts.poppins(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.greenAccent,
                            side: const BorderSide(color: Colors.greenAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.markTripComplete(trip),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: Text('Complete', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => CancellationBottomSheet.show(
                          passengerPhone: trip.passengerPhone,
                          passengerName: trip.passengerName,
                          onConfirmCancel: (reason) async {
                            await _firebaseCancelTrip(trip, reason);
                          },
                        ),
                        icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                        tooltip: 'Cancel Trip',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case TripStatus.active:
      case TripStatus.accepted:
        color = Colors.cyanAccent; label = 'ACTIVE'; break;
      case TripStatus.completed:
        color = Colors.greenAccent; label = 'DONE'; break;
      default:
        color = Colors.redAccent; label = 'CANCELLED';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Future<void> _callPassenger(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _firebaseCancelTrip(TripModel trip, String reason) async {
    // Delegates to controller's Firestore update
    await controller.markTripComplete(trip); // Reuse or add separate cancel
  }

  Widget _glassIcon(IconData icon) {
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
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
