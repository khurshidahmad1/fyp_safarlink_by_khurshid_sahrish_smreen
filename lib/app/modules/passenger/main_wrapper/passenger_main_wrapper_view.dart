import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'passenger_main_wrapper_controller.dart';
import '../home/passenger_home_view.dart';
import '../bookings/passenger_bookings_view.dart';
import '../profile/passenger_profile_view.dart';

class PassengerMainWrapperView extends GetView<PassengerMainWrapperController> {
  const PassengerMainWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep screens alive to avoid resetting inputs or query states
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              PassengerHomeView(),
              PassengerBookingsView(),
              PassengerProfileView(),
            ],
          )),
      bottomNavigationBar: _buildGlassmorphicNavBar(),
    );
  }

  // ── Premium Glassmorphic BottomNavigationBar ──────────────────────────────
  Widget _buildGlassmorphicNavBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.2,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavBarItem(0, Icons.home, 'Home'),
                      _buildNavBarItem(1, Icons.directions_car, 'My Trips'),
                      _buildNavBarItem(2, Icons.person, 'Account'),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final isSelected = controller.currentIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00BFA5) : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? const Color(0xFF00BFA5) : Colors.white38,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inline declaration of GoogleFonts inside this file to avoid compilation warnings if imported incorrectly
class GoogleFonts {
  static TextStyle poppins({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
