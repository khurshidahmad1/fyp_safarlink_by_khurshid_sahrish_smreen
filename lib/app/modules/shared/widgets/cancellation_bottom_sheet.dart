import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable cancellation bottom sheet.
/// Usage:
///   CancellationBottomSheet.show(
///     passengerPhone: '+923001234567',
///     onConfirmCancel: (reason) => controller.cancelRide(reason),
///   );
class CancellationBottomSheet {
  static const List<String> _reasons = [
    'Passenger unreachable',
    'Emergency situation',
    'Vehicle breakdown',
    'Route not feasible',
    'Passenger requested cancel',
    'Prior commitment conflict',
    'Other',
  ];

  static void show({
    required String passengerPhone,
    required Function(String reason) onConfirmCancel,
    String passengerName = 'Passenger',
  }) {
    final RxString selectedReason = _reasons.first.obs;

    Get.bottomSheet(
      _CancellationSheet(
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        selectedReason: selectedReason,
        reasons: _reasons,
        onConfirmCancel: onConfirmCancel,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

class _CancellationSheet extends StatelessWidget {
  final String passengerName;
  final String passengerPhone;
  final RxString selectedReason;
  final List<String> reasons;
  final Function(String reason) onConfirmCancel;

  const _CancellationSheet({
    required this.passengerName,
    required this.passengerPhone,
    required this.selectedReason,
    required this.reasons,
    required this.onConfirmCancel,
  });

  Future<void> _callPassenger() async {
    final uri = Uri.parse('tel:$passengerPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Unable to make call',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0D1B2A).withValues(alpha: 0.97),
                const Color(0xFF0C101A).withValues(alpha: 0.99),
              ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orangeAccent.withValues(alpha: 0.12),
                  border: Border.all(
                      color: Colors.orangeAccent.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.orangeAccent, size: 40),
              ),
              const SizedBox(height: 16),

              Text(
                'Before You Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try calling $passengerName first.\nFrequent cancellations affect your rating.',
                style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // ── MASSIVE Call Now Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton.icon(
                  onPressed: _callPassenger,
                  icon: const Icon(Icons.call_rounded,
                      size: 26, color: Colors.white),
                  label: Text(
                    'CALL NOW',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 10,
                    shadowColor:
                        const Color(0xFF00BFA5).withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Divider(color: Colors.white12),
              const SizedBox(height: 16),

              // ── Cancellation Reason Dropdown ─────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'REASON FOR CANCELLATION',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => _buildReasonDropdown()),
              const SizedBox(height: 24),

              // ── Confirm Cancel Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    onConfirmCancel(selectedReason.value);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Confirm Cancellation',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Keep Ride Button ─────────────────────────────────────────
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Keep Ride',
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedReason.value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A2636),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.white60),
              items: reasons
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) selectedReason.value = val;
              },
            ),
          ),
        ),
      ),
    );
  }
}
