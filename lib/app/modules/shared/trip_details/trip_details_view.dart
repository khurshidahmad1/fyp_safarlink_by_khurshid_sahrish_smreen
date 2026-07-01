import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_details_controller.dart';

class TripDetailsView extends GetView<TripDetailsController> {
  const TripDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Aurora Gradient Background ──────────────────────────────────────
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
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)));
              }

              final booking = controller.bookingData;
              if (booking.isEmpty) {
                return Center(
                  child: Text(
                    "Trip details not found.",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                );
              }

              final String status = booking['status'] ?? 'pending';
              // Support both field conventions (bookings vs ride_requests)
              final String departure = booking['departureCity'] ?? booking['fromCity'] ?? 'Departure';
              final String destination = booking['destinationCity'] ?? booking['toCity'] ?? 'Destination';
              final int fare = (booking['totalFare'] ?? booking['fare'] as num?)?.toInt() ?? 0;
              final String tripType = booking['tripType'] ?? 'One-Way';

              final bool isDriver = controller.userRole.value == 'driver';
              final profile = isDriver ? controller.passengerProfile : controller.driverProfile;
              final String counterpartName = profile['name'] ?? (isDriver ? (booking['passengerName'] ?? 'Passenger') : (booking['driverName'] ?? 'Driver'));
              final String counterpartPhone = profile['phone'] ?? profile['phoneNumber'] ?? (isDriver ? (booking['passengerPhone'] ?? booking['passengerPhoneNumber'] ?? 'No Phone') : (booking['driverPhone'] ?? 'No Phone'));
              final String counterpartPhoto = profile['profilePhotoUrl'] ?? '';

              return Column(
                children: [
                  // App Bar
                  _buildHeader(),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Status Banner ──
                          _buildStatusCard(status),
                          const SizedBox(height: 20),

                          // ── Role-Aware Counterpart Profile Card ──
                          _buildRoleAwareProfileCard(
                            counterpartName,
                            counterpartPhone,
                            counterpartPhoto,
                            booking,
                          ),
                          const SizedBox(height: 20),

                          // ── Communication Actions (Call + WhatsApp) ──
                          if (status == 'confirmed' || status == 'accepted')
                            _buildCommunicationRow(counterpartPhone),
                          if (status == 'confirmed' || status == 'accepted')
                            const SizedBox(height: 20),

                          // ── Trip Specifications Card ──
                          _buildSpecsCard(departure, destination, tripType, fare, booking),
                          const SizedBox(height: 20),

                          // ── Token Payment Verification Card ──
                          _buildTokenPaymentSection(booking),
                          const SizedBox(height: 20),

                          // ── Operational Actions (Complete / Cancel) ──
                          if (status == 'confirmed' || status == 'accepted') ...[
                            if (controller.userRole.value == 'driver') ...[
                              _buildCompleteTripButton(),
                              const SizedBox(height: 14),
                            ],
                            _buildCancelTripButton(context, counterpartPhone),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            "Trip Details",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Card ────────────────────────────────────────────────────────────
  Widget _buildStatusCard(String status) {
    Color statusColor = Colors.cyanAccent;
    IconData statusIcon = Icons.info_outline;

    if (status == 'confirmed' || status == 'accepted') {
      statusColor = const Color(0xFF00BFA5);
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'completed') {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.stars;
    } else if (status == 'cancelled' || status == 'rejected') {
      statusColor = Colors.redAccent;
      statusIcon = Icons.cancel_outlined;
    }

    return _glassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRIP STATUS',
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(color: statusColor, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ROLE-AWARE COUNTERPART PROFILE CARD
  //  Passenger sees: Driver Name, Vehicle, Phone with dial
  //  Driver sees: Passenger Name, Route Addas, Phone with dial
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRoleAwareProfileCard(
    String name,
    String phone,
    String photo,
    Map<String, dynamic> booking,
  ) {
    final bool isDriver = controller.userRole.value == 'driver';
    final String label = isDriver ? 'PASSENGER INFO' : 'DRIVER INFO';

    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Label ──
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Avatar + Name Row ──
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF00BFA5),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // ── Phone Number Display ──
                    Row(
                      children: [
                        const Text('📞 ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            isDriver ? 'Passenger Phone: $phone' : 'Driver Phone: $phone',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF00BFA5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.makeCall(phone),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.3)),
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Color(0xFF00BFA5),
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 14),

          // ── Role-specific metadata rows ──
          if (isDriver) ...[
            // DRIVER VIEW: Show Passenger's Departure & Destination Addas
            _metadataRow(
              Icons.circle,
              Colors.greenAccent,
              'Departure Adda',
              booking['departureCity'] ?? booking['fromCity'] ?? 'N/A',
            ),
            const SizedBox(height: 10),
            _metadataRow(
              Icons.location_on,
              Colors.redAccent,
              'Destination Adda',
              booking['destinationCity'] ?? booking['toCity'] ?? 'N/A',
            ),
            const SizedBox(height: 10),
            _metadataRow(
              Icons.event_seat,
              Colors.amberAccent,
              'Seats Booked',
              '${booking['seats'] ?? booking['seatsRequested'] ?? 1}',
            ),
          ] else ...[
            // PASSENGER VIEW: Show Driver's Vehicle Details
            _buildVehicleDetailsRows(),
          ],
        ],
      ),
    );
  }

  /// Renders driver vehicle metadata from the fetched driverVehicleData
  Widget _buildVehicleDetailsRows() {
    return Obx(() {
      final vehicle = controller.driverVehicleData;
      final primaryVehicle = vehicle['primaryVehicle'] as Map<String, dynamic>? ?? {};
      final String carModel = primaryVehicle['model'] ?? vehicle['carModel'] ?? 'Not Available';
      final String carColor = primaryVehicle['color'] ?? vehicle['carColor'] ?? '';
      final String plateNumber = primaryVehicle['plateNumber'] ?? vehicle['plateNumber'] ?? '';

      return Column(
        children: [
          _metadataRow(
            Icons.directions_car,
            Colors.cyanAccent,
            'Vehicle',
            carModel,
          ),
          if (carColor.isNotEmpty) ...[
            const SizedBox(height: 10),
            _metadataRow(
              Icons.color_lens_outlined,
              Colors.purpleAccent,
              'Color',
              carColor,
            ),
          ],
          if (plateNumber.isNotEmpty) ...[
            const SizedBox(height: 10),
            _metadataRow(
              Icons.confirmation_number_outlined,
              Colors.orangeAccent,
              'Plate',
              plateNumber,
            ),
          ],
        ],
      );
    });
  }

  /// Reusable metadata row with overflow protection via Expanded
  Widget _metadataRow(IconData icon, Color iconColor, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label:  ',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Communication Row (Call + WhatsApp) ─────────────────────────────────────
  Widget _buildCommunicationRow(String phone) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.makeCall(phone),
            child: _glassContainer(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
              borderColor: const Color(0xFF00BFA5).withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: Color(0xFF00BFA5), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Direct Call',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.openWhatsApp(phone),
            child: _glassContainer(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              color: Colors.greenAccent.withValues(alpha: 0.12),
              borderColor: Colors.greenAccent.withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.message, color: Colors.greenAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'WhatsApp',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Trip Specifications Card ───────────────────────────────────────────────
  Widget _buildSpecsCard(String dep, String dest, String type, int fare, Map<String, dynamic> booking) {
    return _glassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRIP DETAILS',
            style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),

          // Departure & Destination
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  Container(width: 1.5, height: 24, color: Colors.white24),
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dep,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      dest,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),

          // Trip Type & Total Fare
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Type',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Fare',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Rs. $fare',
                        style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Financial metrics (Visible ONLY to driver)
          if (controller.userRole.value == 'driver' && type != 'Manual/Offline') ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Petrol Cost', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
                      Text('Rs. ${(booking['fuelExpense'] as num?)?.round() ?? 0}', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Net Profit', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
                      Text('Rs. ${(booking['driverProfit'] as num?)?.round() ?? 0}', style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TOKEN PAYMENT SECTION — P2P Post-Acceptance Module
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTokenPaymentSection(Map<String, dynamic> booking) {
    final String status = booking['status'] ?? 'pending';
    final bool tokenPaid = booking['tokenPaid'] ?? false;
    final bool isDriver = controller.userRole.value == 'driver';

    // Only render for confirmed/accepted trips
    if (status != 'confirmed' && status != 'accepted') return const SizedBox.shrink();

    // ── DRIVER VIEW MODE ──
    if (isDriver) {
      if (tokenPaid) {
        final int tokenAmount = (booking['tokenAmount'] as num?)?.toInt() ?? 0;
        final String tokenRef = booking['tokenReference'] ?? 'N/A';

        return _glassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: const Color(0xFF00BFA5).withValues(alpha: 0.08),
          borderColor: const Color(0xFF00BFA5).withValues(alpha: 0.35),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user, color: Color(0xFF00BFA5), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🔒 Advance Token Verified & Paid: Rs. $tokenAmount | Trx ID: $tokenRef',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Translucent yellow warning card
        return _glassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: Colors.amberAccent.withValues(alpha: 0.08),
          borderColor: Colors.amberAccent.withValues(alpha: 0.35),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '⏳ Awaiting Passenger Token Advance Payment (EasyPaisa/JazzCash)',
                    style: GoogleFonts.poppins(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    // ── PASSENGER VIEW MODE ──
    if (tokenPaid) {
      final int tokenAmount = (booking['tokenAmount'] as num?)?.toInt() ?? 0;
      final String tokenRef = booking['tokenReference'] ?? 'N/A';

      return _glassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: const Color(0xFF00BFA5).withValues(alpha: 0.08),
        borderColor: const Color(0xFF00BFA5).withValues(alpha: 0.35),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user, color: Color(0xFF00BFA5), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '🔒 Token Paid & Verified: Rs. $tokenAmount  |  Trx ID: $tokenRef',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final bool isExpanded = controller.isTokenFormOpen.value;

      return _glassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox toggle tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: CheckboxListTile(
                value: isExpanded,
                onChanged: (val) => controller.isTokenFormOpen.value = val ?? false,
                activeColor: const Color(0xFF00BFA5),
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid Advance Token?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ٹوکن جمع کروا دیا ہے؟',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable form body
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              constraints: BoxConstraints(maxHeight: isExpanded ? 300 : 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isExpanded ? 1.0 : 0.0,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Column(
                      children: [
                        const Divider(color: Colors.white10, height: 1),
                        const SizedBox(height: 14),

                        // Token Amount field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: TextField(
                            controller: controller.tokenAmountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.monetization_on_outlined, color: Color(0xFF00BFA5), size: 20),
                              hintText: 'Enter Paid Token Amount',
                              hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Transaction Reference ID field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: TextField(
                            controller: controller.tokenTrxIdController,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF00BFA5), size: 20),
                              hintText: 'Trx Reference ID (EasyPaisa/JazzCash)',
                              hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () => controller.submitToken(controller.bookingId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BFA5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Submit Token Reference',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Complete Trip Button (Driver Only) ──────────────────────────────────────
  Widget _buildCompleteTripButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isCompleting.value ? null : () => controller.completeTrip(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: controller.isCompleting.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Mark Trip as Completed',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
              ),
      )),
    );
  }

  // ── Cancel Trip Button ─────────────────────────────────────────────────────
  Widget _buildCancelTripButton(BuildContext context, String phone) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isCancelling.value ? null : () => _showCancellationFlow(context, phone),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
          foregroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),
          elevation: 0,
        ),
        child: controller.isCancelling.value
            ? const CircularProgressIndicator(color: Colors.redAccent)
            : Text(
                'Cancel Ride',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
              ),
      )),
    );
  }

  // ── Cancellation Flow ──────────────────────────────────────────────────────
  void _showCancellationFlow(BuildContext context, String phone) {
    // Intermediary Dial prompt
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0C101A).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          title: Text(
            'Please Call First 📞',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'We advise calling the counterpart first to align on cancellations. Would you like to call now?',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // close call prompt
                _showReasonDropdownSheet(context); // transition to reason sheet
              },
              child: Text(
                'Bypass & Cancel',
                style: GoogleFonts.poppins(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.makeCall(phone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Call Now',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReasonDropdownSheet(BuildContext context) {
    controller.selectedReason.value = ''; // reset selection

    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C101A).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cancellation Reason',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please select a reason to cancel the ride request.',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Glassmorphic Dropdown field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF0C101A),
                    hint: Text(
                      'Select cancellation reason',
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                    ),
                    value: controller.selectedReason.value.isEmpty ? null : controller.selectedReason.value,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00BFA5)),
                    items: controller.cancellationReasons.map((String reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedReason.value = val;
                      }
                    },
                  ),
                )),
              ),
              const SizedBox(height: 24),

              // Action button - Disabled until reason is selected
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(() {
                  final hasReasonSelected = controller.selectedReason.value.isNotEmpty;
                  return ElevatedButton(
                    onPressed: hasReasonSelected
                        ? () {
                            Get.back(); // close sheet
                            controller.cancelTrip();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirm Cancellation',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasReasonSelected ? Colors.white : Colors.white38,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  UI DESIGN HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _glassContainer({
    required Widget child,
    required BorderRadius borderRadius,
    required EdgeInsetsGeometry padding,
    Color? color,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.04),
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.12),
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
}
