import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'driver_dashboard_controller.dart';
import '../../../routes/app_routes.dart';



class DriverDashboardView extends GetView<DriverDashboardController> {
  const DriverDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _buildFab(),
      body: Stack(
        children: [
          // ── Aurora Gradient ──────────────────────────────────────────────
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
          // Ambient orbs
          Positioned(
            top: -120,
            right: -80,
            child: _glowOrb(const Color(0xFF00BFA5), 300),
          ),
          Positioned(
            bottom: 150,
            left: -100,
            child: _glowOrb(const Color(0xFF1565C0), 260),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isProfileLoading.value) {
                return _buildLoadingShimmer();
              }
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Show KYC CTA if not complete
                    Obx(() => !controller.kycComplete.value
                        ? _buildKycBanner()
                        : const SizedBox.shrink()),

                    // Show vehicle CTA if KYC done but no vehicle
                    Obx(() =>
                        controller.kycComplete.value &&
                                !controller.isCarRegistered.value
                            ? _buildVehicleBanner()
                            : const SizedBox.shrink()),

                    // Stats
                    Obx(() => controller.isCarRegistered.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('YOUR PERFORMANCE'),
                              const SizedBox(height: 12),
                              _buildStatsRow(),
                              const SizedBox(height: 24),
                            ],
                          )
                        : const SizedBox.shrink()),

                    // Calendar
                    _buildSectionLabel('SCHEDULE & AVAILABILITY'),
                    const SizedBox(height: 12),
                    _buildCalendarCard(),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Obx(() => controller.isCarRegistered.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('QUICK ACTIONS'),
                              const SizedBox(height: 12),
                              _buildActionCards(),
                              const SizedBox(height: 24),
                            ],
                          )
                        : const SizedBox.shrink()),

                    // Live Requests Hub
                    Obx(() => controller.isCarRegistered.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('LIVE REQUESTS HUB'),
                              const SizedBox(height: 12),
                              _buildLiveRequestsTeaser(),
                            ],
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildFloatingBottomNavBar(),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    'Hello, ${controller.driverName.value.split(' ').first}! 👋',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              Obx(() => Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFF00BFA5), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        controller.addaCity.value.isEmpty
                            ? 'Set your Adda city'
                            : controller.addaCity.value,
                        style: GoogleFonts.poppins(
                            color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        Obx(() => _buildProfileAvatar()),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.EDIT_DRIVER_PROFILE),
      child: _glassContainer(
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.all(3),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF00BFA5),
          backgroundImage: controller.profilePhotoUrl.value.isNotEmpty
              ? NetworkImage(controller.profilePhotoUrl.value)
              : null,
          child: controller.profilePhotoUrl.value.isEmpty
              ? const Icon(Icons.person, color: Colors.white, size: 26)
              : null,
        ),
      ),
    );
  }

  // ── KYC Banner ─────────────────────────────────────────────────────────────
  Widget _buildKycBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _buildGlowCard(
        borderColor: Colors.orangeAccent,
        glowColor: Colors.orangeAccent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_user_outlined,
                  color: Colors.orangeAccent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KYC Verification Required',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text('Complete identity verification to go live',
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: controller.goToKyc,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child:
                  Text('Start', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vehicle Banner ─────────────────────────────────────────────────────────
  Widget _buildVehicleBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _buildGlowCard(
        borderColor: Colors.greenAccent,
        glowColor: Colors.greenAccent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car_outlined,
                  color: Colors.greenAccent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Register Your Vehicle',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text('Add car photos & fare settings to start',
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: controller.goToVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text('Add Car',
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          Obx(() => _statCard(
                label: 'Earnings',
                value: 'Rs. ${controller.earnings.value.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.cyanAccent,
              )),
          const SizedBox(width: 12),
          Obx(() => _statCard(
                label: 'Trips',
                value: '${controller.activeTrips.value}',
                icon: Icons.directions_car_outlined,
                color: const Color(0xFFFFB4A2),
              )),
          const SizedBox(width: 12),
          Obx(() => _statCard(
                label: 'Rating',
                value: controller.rating.value == 0.0
                    ? 'New'
                    : '${controller.rating.value.toStringAsFixed(1)} ★',
                icon: Icons.star_border_outlined,
                color: Colors.amberAccent,
              )),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return _glassContainer(
      width: 148,
      height: 108,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── Interactive Calendar Card ───────────────────────────────────────────────
  Widget _buildCalendarCard() {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: Color(0xFF00BFA5), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Availability Calendar',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
                // Legend
                _calendarLegend(Colors.redAccent, 'Blocked'),
                const SizedBox(width: 10),
                _calendarLegend(Colors.greenAccent, 'Free'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay:
                    DateTime.now().add(const Duration(days: 180)),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) =>
                    isSameDay(controller.selectedDay.value, day),
                onDaySelected: (selectedDay, focusedDay) {
                  controller.selectedDay.value = selectedDay;
                  controller.focusedDay.value = focusedDay;
                  // Long press workaround: tap shows unblock option
                  if (controller.isDateBlocked(selectedDay)) {
                    controller.showUnblockDialog(selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  controller.focusedDay.value = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  // Base day
                  defaultTextStyle: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 13),
                  weekendTextStyle: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 13),
                  outsideTextStyle: GoogleFonts.poppins(
                      color: Colors.white24, fontSize: 13),
                  // Today
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00BFA5)),
                  ),
                  todayTextStyle:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                  // Selected
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF00BFA5),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                  // Markers will be handled by calendarBuilders
                  markerDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  formatButtonVisible: false,
                  leftChevronIcon: const Icon(Icons.chevron_left,
                      color: Colors.white70),
                  rightChevronIcon: const Icon(Icons.chevron_right,
                      color: Colors.white70),
                  headerPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  weekendStyle: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                calendarBuilders: CalendarBuilders(
                  // Custom day cell to colour blocked dates
                  defaultBuilder: (context, day, focusedDay) =>
                      _buildCalendarDay(day, isSelected: false),
                  selectedBuilder: (context, day, focusedDay) =>
                      _buildCalendarDay(day, isSelected: true),
                  todayBuilder: (context, day, focusedDay) =>
                      _buildCalendarDay(day, isToday: true),
                ),
              )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Text(
              'Tap a blocked date to unblock it. Use + to block a selected date.',
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day,
      {bool isSelected = false, bool isToday = false}) {
    final blocked = controller.isDateBlocked(day);
    Color bg = Colors.transparent;
    Color textColor = Colors.white70;
    BoxBorder? border;

    if (blocked) {
      bg = Colors.redAccent.withValues(alpha: 0.25);
      textColor = Colors.redAccent;
      border = Border.all(color: Colors.redAccent.withValues(alpha: 0.5));
    } else if (isSelected) {
      bg = const Color(0xFF00BFA5);
      textColor = Colors.white;
    } else if (isToday) {
      bg = const Color(0xFF00BFA5).withValues(alpha: 0.3);
      textColor = Colors.white;
      border = Border.all(color: const Color(0xFF00BFA5));
    }

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: border,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 13,
              fontWeight:
                  isSelected || blocked ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _calendarLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: controller.showAddBlockDialog,
      backgroundColor: const Color(0xFF00BFA5),
      elevation: 8,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────
  Widget _buildActionCards() {
    return Column(
      children: [
        _actionCard(
          title: 'Requests Hub',
          subtitle: 'View & accept passenger requests',
          icon: Icons.inbox_outlined,
          color: Colors.cyanAccent,
          onTap: controller.goToRequestsHub,
        ),
        const SizedBox(height: 12),
        _actionCard(
          title: 'Trip Management',
          subtitle: 'Track ongoing & past trips',
          icon: Icons.route_outlined,
          color: const Color(0xFFFFB4A2),
          onTap: controller.goToTripManagement,
        ),
        const SizedBox(height: 12),
        _actionCard(
          title: 'Manage Bookings',
          subtitle: 'Active, scheduled, and past trips',
          icon: Icons.book_online_outlined,
          color: Colors.amberAccent,
          onTap: controller.goToBookings,
        ),
        const SizedBox(height: 12),
        _actionCard(
          title: 'Vehicle & Fare Settings',
          subtitle: 'Update car info and fare engine',
          icon: Icons.settings_outlined,
          color: Colors.greenAccent,
          onTap: controller.goToCarRegistration,
        ),
      ],
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: _glassContainer(
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white30, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Live Requests Teaser ───────────────────────────────────────────────────
  Widget _buildLiveRequestsTeaser() {
    return InkWell(
      onTap: controller.goToRequestsHub,
      borderRadius: BorderRadius.circular(20),
      child: _buildGlowCard(
        borderColor: Colors.cyanAccent,
        glowColor: Colors.cyanAccent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.notifications_active_outlined,
                  color: Colors.cyanAccent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Requests Waiting',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text('Tap to open Requests Hub',
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Text('OPEN',
                  style: GoogleFonts.poppins(
                      color: Colors.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading Shimmer ────────────────────────────────────────────────────────
  Widget _buildLoadingShimmer() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF00BFA5)),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Bottom Nav Bar ─────────────────────────────────────────────────────────
  Widget _buildFloatingBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', isActive: true),
              _navItem(Icons.route_outlined, 'Trips', onTap: controller.goToTripManagement),
              _navItem(Icons.inbox_outlined, 'Requests', onTap: controller.goToRequestsHub),
              _navItem(Icons.person_outline, 'Profile', onTap: () => Get.toNamed(AppRoutes.DRIVER_PROFILE_SETTINGS)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF00BFA5) : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? const Color(0xFF00BFA5) : Colors.white38,
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white60,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildGlowCard({
    required Widget child,
    required Color borderColor,
    required Color glowColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _glassContainer({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
