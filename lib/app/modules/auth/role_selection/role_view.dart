import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_controller.dart';

class RoleView extends GetView<RoleController> {
  const RoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF003D45), // Deep Ocean Teal (top)
                  Color(0xFF0C101A), // Dark Midnight Blue (bottom)
                ],
              ),
            ),
          ),
          
          // Responsive Content Layout
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            // 2. Header Section: Top Subtitle
                            Text(
                              "WELCOME TO SAFARLINK",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Header Section: Main Title
                            Text(
                              "How would you like\nto travel today?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            
                            const Spacer(),
                            const SizedBox(height: 32),
                            
                            // 3. Card 1 (Passenger)
                            _buildRoleCard(
                              iconData: Icons.person_outline,
                              iconColor: Colors.cyanAccent,
                              title: "Passenger",
                              subtitle: "Book a ride",
                              onTap: controller.selectPassengerRole,
                            ),
                            const SizedBox(height: 20),
                            
                            // 3. Card 2 (Driver)
                            _buildRoleCard(
                              iconData: Icons.directions_car_outlined,
                              iconColor: const Color(0xFFFFB4A2), // Soft peach/orange
                              title: "Driver",
                              subtitle: "Offer a ride",
                              onTap: controller.selectDriverRole,
                            ),
                            
                            const Spacer(),
                            const SizedBox(height: 32),
                            
                            // 4. Footer (Log out Button)
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: controller.logout,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 36),
                                ),
                                child: Text(
                                  "Log out",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Private Method for Glassmorphic Role Cards
  Widget _buildRoleCard({
    required IconData iconData,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              splashColor: iconColor.withValues(alpha: 0.1),
              highlightColor: iconColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon inside container with neon glow effect
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withValues(alpha: 0.5),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Icon(
                        iconData,
                        size: 64,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
