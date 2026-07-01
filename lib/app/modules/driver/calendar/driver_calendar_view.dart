import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'driver_calendar_controller.dart';

class DriverCalendarView extends GetView<DriverCalendarController> {
  const DriverCalendarView({super.key});

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
          // Glow Orbs
          Positioned(
            top: -100,
            right: -50,
            child: _glowOrb(const Color(0xFF00BFA5), 280),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: _glowOrb(const Color(0xFF1565C0), 240),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // Legend
                  _buildLegend(),
                  const SizedBox(height: 16),

                  // Calendar Container
                  Expanded(
                    child: _buildGlassContainer(
                      borderRadius: BorderRadius.circular(24),
                      child: Obx(() {
                        final booked = controller.bookedDates;

                        return TableCalendar(
                          firstDay: DateTime.utc(2025, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: controller.focusedDay.value,
                          selectedDayPredicate: (day) => isSameDay(controller.selectedDay.value, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            controller.selectedDay.value = selectedDay;
                            controller.focusedDay.value = focusedDay;
                          },
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                            weekendTextStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                            outsideTextStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
                            todayTextStyle: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                            todayDecoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.cyanAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            formatButtonVisible: false,
                            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                            rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
                            weekendStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 11),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              final normalized = DateTime(day.year, day.month, day.day);
                              if (booked.contains(normalized)) {
                                return _buildSpecialDayCell(day, Colors.redAccent);
                              }
                              return null;
                            },
                            outsideBuilder: (context, day, focusedDay) {
                              final normalized = DateTime(day.year, day.month, day.day);
                              if (booked.contains(normalized)) {
                                return _buildSpecialDayCell(day, Colors.redAccent.withValues(alpha: 0.4));
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showManualBookingSheet(context),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
              onPressed: () => Get.back(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text(
              "Schedule Calendar",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Lock dates with manual offline entries",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(const Color(0xFF00BFA5), "Available"),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.redAccent, "Booked / Blocked"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialDayCell(DateTime day, Color color) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1.2),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(12.0),
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

  // ── Manual Offline Booking bottom sheet ─────────────────────────────────────
  void _showManualBookingSheet(BuildContext context) {
    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C101A).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manual Offline Booking',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Display Selected Date
                Obx(() => Text(
                  'Selected Date: ${controller.selectedDay.value.day}/${controller.selectedDay.value.month}/${controller.selectedDay.value.year}',
                  style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold),
                )),
                const SizedBox(height: 16),

                _buildInputLabel("Passenger Name"),
                _buildInputBox(
                  controller: controller.passengerNameController,
                  hint: "e.g. Khurshid",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),

                _buildInputLabel("Passenger Phone"),
                _buildInputBox(
                  controller: controller.passengerPhoneController,
                  hint: "e.g. +923001234567",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                _buildInputLabel("Departure Adda"),
                _buildInputBox(
                  controller: controller.departureController,
                  hint: "e.g. Lahore Adda",
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),

                _buildInputLabel("Destination City"),
                _buildInputBox(
                  controller: controller.destinationController,
                  hint: "e.g. Sahiwal",
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : () => controller.submitOfflineBooking(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Confirm & Lock Date',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
}
