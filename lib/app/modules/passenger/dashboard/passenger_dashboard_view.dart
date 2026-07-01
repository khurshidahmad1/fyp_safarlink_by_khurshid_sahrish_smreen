import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'passenger_dashboard_controller.dart';

class PassengerDashboardView extends GetView<PassengerDashboardController> {
  const PassengerDashboardView({super.key});

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchBoxSection(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Obx(() {
                      if (controller.isSearching.value) {
                        return _buildShimmerLoading();
                      }
                      if (controller.discoveredDrivers.isEmpty) {
                        if (controller.hasSearched.value) {
                          return _buildNoDriversFound();
                        }
                        return _buildInitialGreeting();
                      }
                      return _buildDriversList();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your Inter-City Ride 👋',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Direct connections with trusted local captains',
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBoxSection() {
    return Row(
      children: [
        Expanded(
          child: _glassContainer(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: controller.searchController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter base adda city...',
                hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00BFA5), size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 0),
              ),
              onSubmitted: (value) => controller.searchDrivers(value),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _glassIconButton(
          icon: Icons.search,
          onTap: () => controller.searchDrivers(controller.searchController.text),
        ),
      ],
    );
  }

  Widget _buildInitialGreeting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.explore_outlined,
              size: 56,
              color: Color(0xFF00BFA5),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Explore Captains',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search by city to view available inter-city captains',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDriversFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withValues(alpha: 0.05),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15)),
            ),
            child: const Icon(
              Icons.no_accounts,
              size: 52,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No Captains Registered',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No active captains found in this city yet.',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.15),
      child: ListView.builder(
        itemCount: 3,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriversList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.discoveredDrivers.length,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, index) {
        final driver = controller.discoveredDrivers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => Get.toNamed(
              '/car-details',
              arguments: {'driverId': driver['driverId'], 'driver': driver},
            ),
            child: _glassContainer(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF00BFA5),
                    backgroundImage: driver['profilePhotoUrl'].toString().isNotEmpty
                        ? NetworkImage(driver['profilePhotoUrl'])
                        : null,
                    child: driver['profilePhotoUrl'].toString().isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // CRITICAL: Wrapped in Expanded to prevent horizontal overflow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver['name'] ?? 'Captain',
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
                          '${driver['carBrand']} • ${driver['carModel']} (${driver['totalSeats']} Seats)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Rating Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          driver['rating'].toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
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
