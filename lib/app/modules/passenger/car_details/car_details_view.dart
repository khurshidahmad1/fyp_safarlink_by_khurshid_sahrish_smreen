import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:table_calendar/table_calendar.dart';
import 'car_details_controller.dart';

class CarDetailsView extends GetView<CarDetailsController> {
  const CarDetailsView({super.key});

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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildAppBar(),
                          const SizedBox(height: 20),
                          _buildVehicleHeroSection(),
                          const SizedBox(height: 24),
                          _buildDriverSummaryCard(),
                          const SizedBox(height: 24),
                          _buildAvailabilityCalendarCard(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildFixedBottomActionBar(),
                ],
              );
            }),
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
          'Vehicle Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Vehicle Hero Image Section ─────────────────────────────────────────────
  Widget _buildVehicleHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Photos Slider Track
        SizedBox(
          height: 220,
          child: Obx(() {
            final photos = controller.vehiclePhotos;
            if (photos.isEmpty) {
              return _glassContainer(
                borderRadius: BorderRadius.circular(24),
                padding: EdgeInsets.zero,
                child: Container(
                  color: Colors.white.withValues(alpha: 0.02),
                  child: const Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 72,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photoUrl = photos[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == photos.length - 1 ? 0 : 12),
                  child: SizedBox(
                    width: 300,
                    child: _glassContainer(
                      borderRadius: BorderRadius.circular(24),
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: photoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00BFA5),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  child: const Center(
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 52,
                                      color: Color(0xFF00BFA5),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white.withValues(alpha: 0.02),
                                child: const Center(
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 52,
                                    color: Color(0xFF00BFA5),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 16),

        // Text & Badge Row - wrapped inside Row with Expanded to prevent horizontal overflow
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.carBrand.value} ${controller.carModel.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.isAc.value ? 'Fully Air-Conditioned Class' : 'Standard Non-AC Ride',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.3)),
              ),
              child: Text(
                '${controller.totalSeats.value} SEATS',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF00BFA5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Driver Details Panel ───────────────────────────────────────────────────
  Widget _buildDriverSummaryCard() {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF00BFA5),
            backgroundImage: controller.driverPhoto.value.isNotEmpty
                ? NetworkImage(controller.driverPhoto.value)
                : null,
            child: controller.driverPhoto.value.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      'Active Captain',
                      style: GoogleFonts.poppins(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final double rating = controller.driverRating.value;
                    final int fullStars = rating.floor();
                    final bool hasHalfStar = (rating - fullStars) >= 0.5;
                    
                    if (index < fullStars) {
                      return const Icon(Icons.star, color: Colors.amber, size: 12);
                    } else if (index == fullStars && hasHalfStar) {
                      return const Icon(Icons.star_half, color: Colors.amber, size: 12);
                    } else {
                      return const Icon(Icons.star_border, color: Colors.amber, size: 12);
                    }
                  }),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.driverRating.value.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TableCalendar Blocked Dates Widget ──────────────────────────────────────
  Widget _buildAvailabilityCalendarCard() {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFF00BFA5), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'CAPTAIN AVAILABILITY SCHEDULE',
                    style: GoogleFonts.poppins(
                      color: Colors.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
              weekendStyle: GoogleFonts.poppins(color: Color(0xFF00BFA5).withValues(alpha: 0.8), fontSize: 11),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              weekendTextStyle: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 12),
              todayDecoration: const BoxDecoration(
                color: Color(0xFF00BFA5),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            // Grey out and disable calendarBlockedDates
            enabledDayPredicate: (day) => !controller.isDateBlocked(day),
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, focusedDay) {
                if (controller.isDateBlocked(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Glowing Fixed Action Button ────────────────────────────────────────────
  Widget _buildFixedBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.2)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.toNamed(
              '/booking-setup',
              arguments: {'driverId': controller.driverId},
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              elevation: 0,
            ),
            child: Text(
              'Book Ride',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
