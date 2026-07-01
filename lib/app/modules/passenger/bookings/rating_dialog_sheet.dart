import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingDialogSheet extends StatefulWidget {
  final String bookingId;
  final String driverId;
  final String driverName;

  const RatingDialogSheet({
    super.key,
    required this.bookingId,
    required this.driverId,
    required this.driverName,
  });

  @override
  State<RatingDialogSheet> createState() => _RatingDialogSheetState();
}

class _RatingDialogSheetState extends State<RatingDialogSheet> {
  int _selectedRating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 1. Write review to /reviews collection
      await firestore.collection('reviews').add({
        'bookingId': widget.bookingId,
        'driverId': widget.driverId,
        'rating': _selectedRating,
        'comment': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Mark booking as reviewed locally in the booking document
      await firestore.collection('bookings').doc(widget.bookingId).update({
        'isReviewed': true,
      });

      // 3. Recalculate driver average rating
      final reviewsQuery = await firestore
          .collection('reviews')
          .where('driverId', isEqualTo: widget.driverId)
          .get();

      double totalStars = 0;
      int count = reviewsQuery.docs.length;
      for (var doc in reviewsQuery.docs) {
        totalStars += (doc.data()['rating'] as num).toDouble();
      }

      double averageRating = count > 0 ? (totalStars / count) : 5.0;

      // Update in users and drivers collections
      final batch = firestore.batch();
      batch.update(firestore.collection('users').doc(widget.driverId), {
        'rating': averageRating,
      });
      batch.update(firestore.collection('drivers').doc(widget.driverId), {
        'averageRating': averageRating,
      });
      await batch.commit();

      Get.back(); // Close bottom sheet
      Get.snackbar(
        "Review Submitted 🎉",
        "Thank you for sharing your experience!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to submit review: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: PopScope(
        canPop: false,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C101A).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Rate Your Ride 🌟',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How was your journey with Captain ${widget.driverName}?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Interactive 5 Star Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final int starValue = index + 1;
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedRating = starValue;
                        });
                      },
                      icon: Icon(
                        starValue <= _selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Optional feedback comment input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Additional Feedback (Optional)',
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: TextField(
                    controller: _commentController,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Tell us about cleanliness, safety, or timing...",
                      hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions: Cancel & Submit
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting ? null : () => Get.back(),
                        child: Text(
                          'Skip Review',
                          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Submit Review',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
