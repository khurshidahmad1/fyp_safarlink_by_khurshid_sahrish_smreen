import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'passenger_home_controller.dart';

class PassengerHomeView extends GetView<PassengerHomeController> {
  const PassengerHomeView({super.key});

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
                  _buildSingleSearchField(),
                  
                  // Autocomplete dropdown overlays
                  Obx(() {
                    if (controller.citySuggestions.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.citySuggestions.length,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withValues(alpha: 0.08),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final suggestion = controller.citySuggestions[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, color: Color(0xFF00BFA5), size: 16),
                            title: Text(
                              suggestion,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                            ),
                            onTap: () => controller.selectCity(suggestion),
                          );
                        },
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 20),
                  
                  // Scrollable Available Driver Grid/List
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Hello, ${controller.passengerName.value} 👋',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(height: 4),
              Text(
                'Find your inter-city captain',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Get.toNamed('/passenger-profile'),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00BFA5), width: 1.5),
            ),
            child: Obx(() => CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  backgroundImage: controller.passengerPhotoUrl.value.isNotEmpty
                      ? NetworkImage(controller.passengerPhotoUrl.value)
                      : null,
                  child: controller.passengerPhotoUrl.value.isEmpty
                      ? const Icon(Icons.person, color: Colors.white60)
                      : null,
                )),
          ),
        ),
      ],
    );
  }

  // ── Single Search Input Field ──────────────────────────────────────────────
  Widget _buildSingleSearchField() {
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
                hintText: 'Enter Adda City (e.g., Okara)...',
                hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
                prefixIcon: const Icon(Icons.location_searching, color: Color(0xFF00BFA5), size: 18),
                prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
              ),
              onSubmitted: (val) => controller.executeDriverDiscovery(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _glassIconButton(
          icon: Icons.search,
          onTap: () => controller.executeDriverDiscovery(),
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
              Icons.directions_car,
              size: 56,
              color: Color(0xFF00BFA5),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Explore Ride Captains',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search by Adda City to see active captains',
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
            'No Captains Found',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No active captains registered in "${controller.searchController.text.split(',').first}" yet.',
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
              arguments: {'driverId': driver['driverId']},
            ),
            child: _glassContainer(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left: Car Thumbnail/Icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Icon(
                        Icons.directions_car,
                        color: Color(0xFF00BFA5),
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Center: Car Brand/Model & Driver's Name with active rating stars row
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${driver['carBrand']} • ${driver['carModel']} (${driver['totalSeats']} Seats)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              driver['name'] ?? 'Captain',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            if (driver['isVerified'] == true) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.cyanAccent, size: 12),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Active rating star row
                        Row(
                          children: List.generate(5, (index) {
                            final double rating = (driver['rating'] as num?)?.toDouble() ?? 5.0;
                            final int fullStars = rating.floor();
                            final bool hasHalfStar = (rating - fullStars) >= 0.5;

                            if (index < fullStars) {
                              return const Icon(Icons.star, color: Colors.amber, size: 10);
                            } else if (index == fullStars && hasHalfStar) {
                              return const Icon(Icons.star_half, color: Colors.amber, size: 10);
                            } else {
                              return const Icon(Icons.star_border, color: Colors.amber, size: 10);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right: Neon Fare pricing/Book badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'BOOK',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF00BFA5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
