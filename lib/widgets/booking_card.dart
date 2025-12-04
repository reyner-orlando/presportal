import 'package:flutter/material.dart';
import '../models/booking.dart';
// import '../services/booking_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (booking.status) {
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Rejected':
      case 'Declined':
        statusColor = Colors.red;
        break;
      case 'Pending':
      default:
        statusColor = Colors.orange;
        break;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER — TITLE + STATUS BADGE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.activityType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            // Pakai statusColor dengan opacity untuk background (biar soft)
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            booking.status.toUpperCase(),
            style: TextStyle( // Hapus const karena warnanya dinamis
              fontSize: 12,
              // Pakai statusColor yang solid untuk teks
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
              ],
            ),

            const SizedBox(height: 12),

            // VENUE
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.venueName,
                    style: const TextStyle(fontSize: 15),
                  ),
                )
              ],
            ),

            const SizedBox(height: 8),

            // STUDENT
            Row(
              children: [
                const Icon(Icons.person, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Text(
                  booking.studentName,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // DATE & TIME
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(booking.date),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // SEPARATOR
            Container(
              height: 1,
              color: Colors.grey.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),

            // BOOKING ID
            Row(
              children: [
                const Icon(Icons.confirmation_num,
                    color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Booking ID: ${booking.bookingId}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format tanggal menjadi lebih cantik
  String _formatDateTime(DateTime date) {
    final d = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final t = booking.timeSlot;
    return "$d  ·  $t";
  }
}
