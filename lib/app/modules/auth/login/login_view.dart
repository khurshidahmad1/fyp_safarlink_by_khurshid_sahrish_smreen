import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Main Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF003D45), // Deep Ocean Teal (top)
                  Color(0xFF0C101A), // Dark Midnight Blue/Charcoal (bottom)
                ],
              ),
            ),
          ),
          
          // Content Layout
          Column(
            children: [
              // 2. Top Section (Centered & Spaced from Top)
              Expanded(
                flex: 55,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Neon Glowing Container wrapping white Icons.directions_car_rounded
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Subtitle
                            Text(
                              "Welcome to the future of travel.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Title
                            Text(
                              "Safarlink",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 3. Bottom Section (The Glassmorphism Panel)
              Expanded(
                flex: 45,
                child: SizedBox.expand(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          border: const Border(
                            top: BorderSide(
                              color: Colors.white24,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
                          child: Column(
                            children: [
                              // 4. Buttons Stacked
                              Expanded(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Primary Button (Phone)
                                        Container(
                                          height: 56,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(28),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFE6B24).withValues(alpha: 0.35),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () => Get.toNamed(AppRoutes.PHONE_INPUT),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFE6B24),
                                              foregroundColor: Colors.white,
                                              shape: const StadiumBorder(),
                                              elevation: 0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.phone_iphone,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  "Continue with Phone",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Secondary Button (Google)
                                        SizedBox(
                                          height: 56,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: controller.loginWithGoogle,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF1E293B),
                                              shape: const StadiumBorder(),
                                              elevation: 0,
                                            ),
                                            child: Obx(
                                              () => controller.isLoadingGoogle.value
                                                  ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const GoogleLogoWidget(size: 22),
                                                        const SizedBox(width: 12),
                                                        Text(
                                                          "Continue with Google",
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF1E293B), // Dark Slate
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Tertiary Button (Email)
                                        SizedBox(
                                          height: 56,
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            onPressed: () => Get.toNamed(AppRoutes.EMAIL_AUTH),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(
                                                color: Colors.white54,
                                                width: 1.5,
                                              ),
                                              shape: const StadiumBorder(),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.mail_outline,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  "Continue with Email",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // 5. Footer (Terms & Privacy)
                              SafeArea(
                                top: false,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: GestureDetector(
                                    onTap: controller.showTermsAndPrivacy,
                                    child: Text(
                                      "Terms & Privacy",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset center = Offset(r, r);
    final double strokeWidth = size.width * 0.22;
    final Rect rect = Rect.fromCircle(center: center, radius: r - strokeWidth / 2);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Green arc (bottom-left to bottom-right, ~45 to 140 deg)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.785, 1.66, false, paint);

    // Yellow arc (left, ~140 to 220 deg)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.44, 1.40, false, paint);

    // Red arc (top, ~220 to 315 deg)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.44, 1.66, false, paint);

    // Blue arc (right, ~315 to 45 deg)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.785, 1.57, false, paint);

    // Blue horizontal bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeWidth / 2,
        r,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
