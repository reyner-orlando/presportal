import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../widgets/booking_card.dart';

class UserBookingHistory extends StatelessWidget {
  final String userId;

  const UserBookingHistory({
    super.key,
    required this.userId
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Booking History"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userid', isEqualTo: userId) // Filter User
            .orderBy('date', descending: true)     // Terbaru di atas
            .snapshots(),
        builder: (context, snapshot) {
          // --- ERROR & LOADING STATE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("No bookings yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // --- DATA LIST ---
          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // [KUNCI PERUBAHAN DI SINI]
              // 1. Ubah data mentah (Map) menjadi Object Booking
              final bookingObject = Booking.fromMap(doc.id, data);

              // 2. Masukkan object tersebut ke Widget BookingCard
              return BookingCard(booking: bookingObject);
            },
          );
        },
      ),
    );
  }
}